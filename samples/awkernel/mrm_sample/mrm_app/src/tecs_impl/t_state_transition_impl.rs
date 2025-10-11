use crate::tecs_global::*;
use crate::tecs_celltype::t_state_transition::*;
use crate::tecs_signature::s_state_transition::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SStateTransition for EStateForTStateTransition{

	fn normalize_yaw(&'static self, yaw: &f64) -> f64{
		(yaw.sin()).atan2(yaw.cos())
	}
	fn predict_next_state(&'static self, x_curr: &nalgebra::Matrix6x1<f64>, dt: &f64) -> nalgebra::Vector6<f64>{
		let x = x_curr[(IDX_X as usize, 0)];
		let y = x_curr[(IDX_Y as usize, 0)];
		let yaw = x_curr[(IDX_YAW as usize, 0)];
		let yaw_bias = x_curr[(IDX_YAWB as usize, 0)];
		let vx = x_curr[(IDX_VX as usize, 0)];
		let wz = x_curr[(IDX_WZ as usize, 0)];

		let mut x_next = nalgebra::Vector6::<f64>::zeros();
		let yaw_b = yaw + yaw_bias;
		x_next[(IDX_X as usize, 0)] = x + vx * (yaw_b).cos() * (*dt);
		x_next[(IDX_Y as usize, 0)] = y + vx * (yaw_b).sin() * (*dt);
		x_next[(IDX_YAW as usize, 0)] = self.normalize_yaw(&(yaw + wz * (*dt)));
		x_next[(IDX_YAWB as usize, 0)] = yaw_bias;
		x_next[(IDX_VX as usize, 0)] = vx;
		x_next[(IDX_WZ as usize, 0)] = wz;
		x_next
	}
	fn create_state_transition_matrix(&'static self, x_curr: &nalgebra::Matrix6x1<f64>, dt: &f64) -> nalgebra::Matrix6<f64>{
		let yaw = x_curr[(IDX_YAW as usize, 0)];
		let yaw_bias = x_curr[(IDX_YAWB as usize, 0)];
		let vx = x_curr[(IDX_VX as usize, 0)];

		let mut a = nalgebra::Matrix6::<f64>::identity();
		let yaw_b = yaw + yaw_bias;
		a[(IDX_X as usize, IDX_YAW as usize)] = -vx * (yaw_b).sin() * (*dt);
		a[(IDX_X as usize, IDX_YAWB as usize)] = -vx * (yaw_b).sin() * (*dt);
		a[(IDX_X as usize, IDX_VX as usize)] = (yaw_b).cos() * (*dt);
		a[(IDX_Y as usize, IDX_YAW as usize)] = vx * (yaw_b).cos() * (*dt);
		a[(IDX_Y as usize, IDX_YAWB as usize)] = vx * (yaw_b).cos() * (*dt);
		a[(IDX_Y as usize, IDX_VX as usize)] = (yaw_b).sin() * (*dt);
		a[(IDX_YAW as usize, IDX_WZ as usize)] = *dt;
		a
	}
	fn process_noise_covariance(&'static self, proc_cov_yaw_d: &f64, proc_cov_vx_d: &f64, proc_cov_wz_d: &f64) -> nalgebra::Matrix6<f64>{
		let mut q = nalgebra::Matrix6::<f64>::zeros();
		q[(IDX_X as usize, IDX_X as usize)] = 0.0;
		q[(IDX_Y as usize, IDX_Y as usize)] = 0.0;
		q[(IDX_YAW as usize, IDX_YAW as usize)] = *proc_cov_yaw_d;
		q[(IDX_YAWB as usize, IDX_YAWB as usize)] = 0.0;
		q[(IDX_VX as usize, IDX_VX as usize)] = *proc_cov_vx_d;
		q[(IDX_WZ as usize, IDX_WZ as usize)] = *proc_cov_wz_d;
		q
	}
}

