use crate::tecs_global::*;
use crate::tecs_celltype::t_covariance::*;
use crate::tecs_signature::s_covariance::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SCovariance for ECovForTCovariance<'_>{

	fn ekf_covariance_to_pose_message_covariance(&'static self, p: &nalgebra::Matrix6<f64>) -> nalgebra::Matrix6<f64>{
		let mut cov = nalgebra::Matrix6::<f64>::zeros();

		// Map EKF state covariance P into Pose covariance
		cov[(IDX_X as usize, IDX_X as usize)] = p[(IDX_X as usize, IDX_X as usize)];
		cov[(IDX_X as usize, IDX_Y as usize)] = p[(IDX_X as usize, IDX_Y as usize)];
		cov[(IDX_X as usize, IDX_YAW as usize)] = p[(IDX_X as usize, IDX_YAW as usize)];

		cov[(IDX_Y as usize, IDX_X as usize)] = p[(IDX_Y as usize, IDX_X as usize)];
		cov[(IDX_Y as usize, IDX_Y as usize)] = p[(IDX_Y as usize, IDX_Y as usize)];
		cov[(IDX_Y as usize, IDX_YAW as usize)] = p[(IDX_Y as usize, IDX_YAW as usize)];

		cov[(IDX_YAW as usize, IDX_X as usize)] = p[(IDX_YAW as usize, IDX_X as usize)];
		cov[(IDX_YAW as usize, IDX_Y as usize)] = p[(IDX_YAW as usize, IDX_Y as usize)];
		cov[(IDX_YAW as usize, IDX_YAW as usize)] = p[(IDX_YAW as usize, IDX_YAW as usize)];

		cov
	}
	fn ekf_covariance_to_twist_message_covariance(&'static self, p: &nalgebra::Matrix6<f64>) -> nalgebra::Matrix6<f64>{
		let mut cov = nalgebra::Matrix6::<f64>::zeros();

		// Map EKF state covariance P into Twist covariance
		cov[(IDX_X as usize, IDX_X as usize)] = p[(IDX_VX as usize, IDX_VX as usize)];
		cov[(IDX_X as usize, IDX_YAW as usize)] = p[(IDX_VX as usize, IDX_WZ as usize)];
		cov[(IDX_YAW as usize, IDX_X as usize)] = p[(IDX_WZ as usize, IDX_VX as usize)];
		cov[(IDX_YAW as usize, IDX_YAW as usize)] = p[(IDX_WZ as usize, IDX_WZ as usize)];

		cov
	}
}

