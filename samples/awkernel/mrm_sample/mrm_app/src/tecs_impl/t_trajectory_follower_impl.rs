use crate::tecs_global::*;
use crate::tecs_celltype::t_trajectory_follower::*;
use crate::tecs_signature::{s_kinematic_state::*, s_accel_with_covariance_stamped::*, s_trajectory_follower::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SKinematicState for EKinematicStateSfForTTrajectoryFollower{

	fn send(&'static self, kinematic_state: &KinematicState) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl SAccelWithCovarianceStamped for EAccelForTTrajectoryFollower{

	fn send(&'static self, accel_with_covariance: &AccelWithCovarianceStamped) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl STrajectoryFollower for EReactorForTTrajectoryFollower{

	fn main(&'static self, kinematic_state: &KinematicState, accel: &AccelWithCovarianceStamped, control: &mut Control) {
		let mut lg = self.cell.get_cell_ref();

		// 1) Data readiness check: ensure we have a trajectory to follow
		// Use fix_points directly without copying
		if lg.fix_points.is_empty() {
			let now = awkernel_lib::time::Time::now();
			control.stamp = now;
			control.lateral.stamp = now;
			control.longitudinal.stamp = now;
			control.lateral.steering_tire_angle = 0.0;
			control.longitudinal.velocity = 0.0;
			control.longitudinal.acceleration = -1.0;
			return;
		}

		// 2) Find closest trajectory point to current position
		let ego_pos = &kinematic_state.pose.pose.point;
		let closest_idx = lg.c_traj.find_nearest_index(lg.fix_points.as_slice(), ego_pos) as usize;
		let closest_idx = core::cmp::min(closest_idx, lg.fix_points.len() - 1);
		let closest_traj_point = &lg.fix_points[closest_idx];

		// 3) Compute steering using linearized pure pursuit
		let lat_err = lg.c_pose.calc_lateral_deviation(&closest_traj_point.pose, ego_pos) - *lg.lateral_deviation;
		let yaw_err = lg.c_pose.calc_yaw_deviation(&closest_traj_point.pose, &kinematic_state.pose.pose);

		let vx = kinematic_state.twist.twist.linear.x;
		let lookahead = *lg.min_lookahead + *lg.lookahead_time * vx.abs();
		let kp_lat = 2.0 * (*lg.wheel_base) / (lookahead * lookahead);
		let kd_yaw = 2.0 * (*lg.wheel_base) / lookahead;
		let mut steer = -kp_lat * lat_err - kd_yaw * yaw_err;
		if steer > *lg.steer_lim { steer = *lg.steer_lim; }
		if steer < -*lg.steer_lim { steer = -*lg.steer_lim; }

		// 4) Compute longitudinal command (velocity and acceleration)
		let traj_vel = closest_traj_point.longitudinal_velocity_mps as f64;
		let target_vel = if *lg.use_external_target_vel { *lg.external_target_vel } else { traj_vel };
		let vel_err = vx - target_vel;
		let mut acc = -(*lg.kp_longitudinal) * vel_err;
		if acc > *lg.acc_lim { acc = *lg.acc_lim; }
		if acc < -*lg.acc_lim { acc = -*lg.acc_lim; }

		// 5) Fill control output and timestamps
		let now = awkernel_lib::time::Time::now();
		control.stamp = now;
		control.lateral.stamp = now;
		control.longitudinal.stamp = now;
		control.lateral.steering_tire_angle = steer;
		control.longitudinal.velocity = target_vel;
		control.longitudinal.acceleration = acc;
	}
}

