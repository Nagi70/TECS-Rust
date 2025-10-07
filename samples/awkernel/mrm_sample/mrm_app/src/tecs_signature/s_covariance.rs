use crate::tecs_global::*;
pub trait SCovariance {
	fn ekf_covariance_to_pose_message_covariance(&'static self, p: &nalgebra::Matrix6<f64>)-> nalgebra::Matrix6<f64>;
	fn ekf_covariance_to_twist_message_covariance(&'static self, p: &nalgebra::Matrix6<f64>)-> nalgebra::Matrix6<f64>;
}
