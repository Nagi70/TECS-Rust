use crate::tecs_global::*;
pub trait SStateTransition {
	fn normalize_yaw(&'static self, yaw: &f64)-> f64;
	fn predict_next_state(&'static self, x_curr: &nalgebra::Matrix6x1<f64>, dt: &f64)-> nalgebra::Vector6<f64>;
	fn create_state_transition_matrix(&'static self, x_curr: &nalgebra::Matrix6x1<f64>, dt: &f64)-> nalgebra::Matrix6<f64>;
	fn process_noise_covariance(&'static self, proc_cov_yaw_d: &f64, proc_cov_vx_d: &f64, proc_cov_wz_d: &f64)-> nalgebra::Matrix6<f64>;
}
