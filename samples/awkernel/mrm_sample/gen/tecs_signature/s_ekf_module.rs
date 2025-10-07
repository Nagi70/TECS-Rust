use crate::tecs_global::*;
pub trait SEkfModule {
	fn init(&'static self);
	fn accumulate_delay_time(&'static self, dt: &f64);
	fn find_closest_delay_time_index(&'static self, target_value: &f64)-> i32;
	fn predict_with_delay(&'static self, dt: &f64);
	fn measurement_update_twist(&'static self, twist: &TwistWithCovariance, ccurent_time: &awkernel_lib::time::Time)-> Result<(), EkfModuleError>;
	fn get_current_twist(&'static self, current_time: &awkernel_lib::time::Time, twist: &mut TwistWithCovarianceStamped);
	fn get_current_twist_covariance(&'static self, twist: &mut TwistWithCovariance);
	fn get_current_pose_covariance(&'static self, pose: &mut PoseWithCovariance);
}
