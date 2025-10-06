use crate::tecs_struct_def::*;
pub trait SAccelWithCovarianceStamped {
	fn send(&'static self, accel_with_covariance: &AccelWithCovarianceStamped);
}
