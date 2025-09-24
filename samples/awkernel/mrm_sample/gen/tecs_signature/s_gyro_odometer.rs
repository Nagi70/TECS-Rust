use crate::tecs_struct_def::*;
pub trait SGyroOdometer {
	fn main(&'static self, vehicle_twist: &TwistWithCovarianceStamped, imu: &ImuMsg, twist_with_covariance: &mut TwistWithCovarianceStamped);
}
