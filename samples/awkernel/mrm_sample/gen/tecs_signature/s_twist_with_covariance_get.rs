use crate::tecs_global::*;
pub trait STwistWithCovarianceGet {
	fn pop(&'static self)-> Option<TwistWithCovarianceStamped>;
	fn pop_increment_age(&'static self)-> Option<TwistWithCovarianceStamped>;
}
