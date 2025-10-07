use crate::tecs_global::*;
pub trait SAccelWithCovarianceStamped {
	fn send(&'static self, accel_with_covariance: &AccelWithCovarianceStamped);
}
