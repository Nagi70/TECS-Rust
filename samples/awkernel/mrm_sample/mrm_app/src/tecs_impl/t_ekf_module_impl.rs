use crate::tecs_global::*;
use crate::tecs_celltype::t_ekf_module::*;
use crate::tecs_signature::{s_time_delay_kalman_filter::*, s_state_transition::*, s_measurement::*, s_mahalanobis::*, s_covariance::*, s_utils_geometry::*, s_ekf_module::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SEkfModule for EEkfModuleForTEkfModule<'_>{

	fn init(&'static self) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		// Port of EKFModule::initialize using attributes: initial_pose and tf
		let pose0 = lg.initial_pose; // &PoseWithCovariance
		let tf = lg.tf; // &Transform

		// Build initial state x from initial pose + transform
		let mut x0 = nalgebra::Matrix6x1::<f64>::zeros();
		// position x,y
		x0[(IDX_X as usize, 0)] = pose0.pose.point[0] + tf.translation[0];
		x0[(IDX_Y as usize, 0)] = pose0.pose.point[1] + tf.translation[1];
		// yaw from quaternions (pose + tf)
		let rpy_pose = lg.c_utils.get_rpy(&pose0.pose.orientation);
		let rpy_tf = lg.c_utils.get_rpy(&tf.rotatoin);
		let yaw0 = rpy_pose[2] + rpy_tf[2];
		x0[(IDX_YAW as usize, 0)] = yaw0;
		// yaw bias, velocities
		x0[(IDX_YAWB as usize, 0)] = 0.0;
		x0[(IDX_VX as usize, 0)] = 0.0;
		x0[(IDX_WZ as usize, 0)] = 0.0;

		// Build initial covariance P from initial pose covariance
		let mut p0 = nalgebra::Matrix6::<f64>::zeros();
		// Pose covariance is ordered as XYZRPY => [x(0), y(1), z(2), roll(3), pitch(4), yaw(5)]
		p0[(IDX_X as usize, IDX_X as usize)] = pose0.covariance[(COV_IDX_X as usize, COV_IDX_X as usize)];
		p0[(IDX_Y as usize, IDX_Y as usize)] = pose0.covariance[(COV_IDX_Y as usize, COV_IDX_Y as usize)];
		p0[(IDX_YAW as usize, IDX_YAW as usize)] = pose0.covariance[(COV_IDX_YAW as usize, COV_IDX_YAW as usize)];
		if *lg.enable_yaw_bias_estimation { p0[(IDX_YAWB as usize, IDX_YAWB as usize)] = 0.0001; }
		p0[(IDX_VX as usize, IDX_VX as usize)] = 0.01;
		p0[(IDX_WZ as usize, IDX_WZ as usize)] = 0.01;

		// Initialize Kalman filter with x0 and p0
		lg.c_kalman.init(&x0, &p0);

		// Initialize Simple 1D filters for z, roll, pitch
		let z0 = pose0.pose.point[2];
		let rpy0 = rpy_pose; // already computed
		// Pose covariance is assumed to be ordered as [x,y,z,roll,pitch,yaw]
		let z_var = pose0.covariance[(2, 2)];
		let roll_var = pose0.covariance[(3, 3)];
		let pitch_var = pose0.covariance[(4, 4)];
		lg.var.z_filter.x = z0; lg.var.z_filter.value = z_var;
		lg.var.roll_filter.x = rpy0[0]; lg.var.roll_filter.value = roll_var;
		lg.var.pitch_filter.x = rpy0[1]; lg.var.pitch_filter.value = pitch_var;

		// Reset delay accumulator and aux vars
		for v in lg.var.accumulated_delay_times.iter_mut() { *v = 1.0e15; }
		lg.var.ekf_dt = 0.0;
		lg.var.last_angular_velocity = nalgebra::Vector3::new(0.0, 0.0, 0.0);
	}

	fn accumulate_delay_time(&'static self, dt: &f64) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let n = lg.var.accumulated_delay_times.len();
		if n == 0 { return; }
		for i in (1..n).rev() { lg.var.accumulated_delay_times[i] = lg.var.accumulated_delay_times[i - 1]; }
		lg.var.accumulated_delay_times[0] = 0.0;
		for i in 1..n { lg.var.accumulated_delay_times[i] += *dt; }
	}

	fn find_closest_delay_time_index(&'static self, target_value: &f64) -> i32{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let arr = &lg.var.accumulated_delay_times;
		let n = arr.len();

		if n == 0 { return 0; }
		if *target_value > arr[n - 1] { return n as i32; }
		
		let mut lo = 0usize;
		let mut hi = n; // [lo,hi)
		
		while lo < hi {
			let mid = (lo + hi) / 2;
			if arr[mid] < *target_value {
				lo = mid + 1; 
			} else { 
				hi = mid; 
			}
		}

		let lower = lo;
		if lower == 0 { return 0; }
		if lower >= n { return (n - 1) as i32; }

		let prev = lower - 1;
		let closer_to_prev = (*target_value - arr[prev]) < (arr[lower] - *target_value);
		(if closer_to_prev { prev } else { lower }) as i32
	}

	fn predict_with_delay(&'static self, dt: &f64) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);
		let x_curr = lg.c_kalman.get_latest_x();
		let proc_cov_vx_d = (*lg.proc_stddev_vx_c * *dt).powi(2);
		let proc_cov_wz_d = (*lg.proc_stddev_wz_c * *dt).powi(2);
		let proc_cov_yaw_d = (*lg.proc_stddev_yaw_c * *dt).powi(2);
		let x_next = lg.c_state.predict_next_state(&x_curr, dt);
		let a = lg.c_state.create_state_transition_matrix(&x_curr, dt);
		let q = lg.c_state.process_noise_covariance(&proc_cov_yaw_d, &proc_cov_vx_d, &proc_cov_wz_d);
		lg.c_kalman.predict_with_delay(&x_next, &a, &q);
		lg.var.ekf_dt = *dt;
	}

	fn measurement_update_twist(&'static self, twist: &TwistWithCovarianceStamped, current_time: &awkernel_lib::time::Time) -> Result<(), EkfModuleError>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		// Frame check (C++: expects base_link)
		if lg.var.accumulated_delay_times.len() == 0 { return Ok(()); }
		// C++ 実装は frame_id が異なる場合に警告するが更新は継続する。
		// TECS 環境ではロガーが無い前提のため、ここではスキップせずに続行する。

		// Reset last angular velocity for twist update path (matches C++)
		lg.var.last_angular_velocity = nalgebra::Vector3::new(0.0, 0.0, 0.0);

		// Calculate delay time = (current_time - twist.header.time_stamp) + additional_delay
		let dt = current_time.saturating_duration_since(twist.header.time_stamp);
		let mut delay_time = (dt.as_nanos() as f64) * 1.0e-9 + *lg.twist_additional_delay;
		if delay_time < 0.0 { delay_time = 0.0; }
		let delay_step = self.find_closest_delay_time_index(&delay_time);
		if delay_step < 0 || (delay_step as i32) >= *lg.extend_state_step { return Ok(()); }

		let mut y = nalgebra::Matrix2x1::<f64>::zeros();
		y[(0,0)] = twist.twist.twist.linear.x;
		y[(1,0)] = twist.twist.twist.angular.z;

		// 入力の有限性チェック（C++ の has_nan / has_inf 相当）
		if !y[(0,0)].is_finite() || !y[(1,0)].is_finite() {
			return Err(EkfModuleError::InvalidTwistMeasurement);
		}

		let p_curr = lg.c_kalman.get_latest_p();
		let p_y = p_curr.slice((IDX_VX as usize, IDX_VX as usize), (2, 2)).into_owned();
		let y_ekf = nalgebra::Vector2::<f64>::new(
			lg.c_kalman.get_xelement(&((delay_step as u32) * (*lg.dim_x as u32) + IDX_VX)),
			lg.c_kalman.get_xelement(&((delay_step as u32) * (*lg.dim_x as u32) + IDX_WZ)),
		);
		let distance = lg.c_maha.mahalanobis2d(&y_ekf, &y, &p_y);
		if distance > *lg.twist_gate_dist { return Err(EkfModuleError::TwistGate); }

		let c = lg.c_measure.twist_measurement_matrix();
		let r = lg.c_measure.twist_measurement_covariance(&twist.twist.covariance, lg.twist_smoothing_steps);
		let _ = lg.c_kalman.update_with_delay(&y, &c, &r, &(delay_step as i32));

		// C++: last_angular_velocity_ を測定から更新
		lg.var.last_angular_velocity = nalgebra::Vector3::new(
			twist.twist.twist.angular.x,
			twist.twist.twist.angular.y,
			twist.twist.twist.angular.z,
		);
		Ok(())
	}
	fn get_current_twist(&'static self, current_time: &awkernel_lib::time::Time, twist: &mut TwistWithCovarianceStamped) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let vx = lg.c_kalman.get_xelement(&IDX_VX);
		let wz = lg.c_kalman.get_xelement(&IDX_WZ);
		twist.header.time_stamp = *current_time;
		// Set frame id for parity with C++ implementation
		twist.header.frame_id.clear();
		let _ = twist.header.frame_id.push_str("base_link");
		twist.twist.twist.linear.x = vx;
		twist.twist.twist.angular.z = wz;
	}

	fn get_current_pose(&'static self, current_time: &awkernel_lib::time::Time, get_biased_yaw: &bool, pose: &mut PoseWithCovarianceStamped) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let z = lg.var.z_filter.x;
		let roll = lg.var.roll_filter.x;
		let pitch = lg.var.pitch_filter.x;

		let x = lg.c_kalman.get_xelement(&IDX_X);
		let y = lg.c_kalman.get_xelement(&IDX_Y);
		let biased_yaw = lg.c_kalman.get_xelement(&IDX_YAW);
		let yaw_bias = lg.c_kalman.get_xelement(&IDX_YAWB);
		let yaw = biased_yaw + yaw_bias;

		pose.header.time_stamp = *current_time;
		pose.header.frame_id.clear();
		let _ = pose.header.frame_id.push_str("map"); // C++ の params_.pose_frame_id 相当
		pose.pose.pose.point[0] = x;
		pose.pose.pose.point[1] = y;
		pose.pose.pose.point[2] = z;
		let q = if *get_biased_yaw {
			lg.c_utils.create_quaternion_from_rpy(&roll, &pitch, &biased_yaw)
		} else {
			lg.c_utils.create_quaternion_from_rpy(&roll, &pitch, &yaw)
		};
		pose.pose.pose.orientation = q;
	}

	fn get_current_twist_covariance(&'static self, cov: &mut nalgebra::Matrix6<f64>) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let p = lg.c_kalman.get_latest_p();
		*cov = lg.c_cov.ekf_covariance_to_twist_message_covariance(&p);
	}
	fn get_current_pose_covariance(&'static self, cov: &mut nalgebra::Matrix6<f64>) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let p = lg.c_kalman.get_latest_p();
		*cov = lg.c_cov.ekf_covariance_to_pose_message_covariance(&p);
		// C++ 実装同様、z/roll/pitch の分散は 1D フィルタの分散で上書き
		cov[(COV_IDX_Z as usize, COV_IDX_Z as usize)] = lg.var.z_filter.value;
		cov[(COV_IDX_ROLL as usize, COV_IDX_ROLL as usize)] = lg.var.roll_filter.value;
		cov[(COV_IDX_PITCH as usize, COV_IDX_PITCH as usize)] = lg.var.pitch_filter.value;
	}
}

