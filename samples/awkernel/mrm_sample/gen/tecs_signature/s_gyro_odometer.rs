use crate::tecs_global::*;
pub trait SGyroOdometer {
	fn main(&'static self, vehicle_twist: &TwistWithCovarianceStamped, imu: &ImuMsg, twist_with_covariance: &mut TwistWithCovarianceStamped);
}
