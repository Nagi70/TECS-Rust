use crate::tecs_global::*;
pub trait STwistWithCovarianceStamped {
	fn send(&'static self, twist_with_covariance: &TwistWithCovarianceStamped);
}
