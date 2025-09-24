use crate::tecs_struct_def::*;
pub trait STwistWithCovarianceGet {
	fn pop(&'static self)-> Result<TwistWithCovarianceStamped>;
	fn pop_increment_age(&'static self)-> Result<TwistWithCovarianceStamped>;
}
