use crate::tecs_struct_def::*;
pub trait STwistWithCovarianceStamped {
	fn send(&'static self, twist_with_covariance: &TwistWithCovarianceStamped);
}
