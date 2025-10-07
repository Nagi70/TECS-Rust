use crate::tecs_global::*;
pub trait STwistWithCovarianceSet {
	fn push(&'static self, twist: &TwistWithCovarianceStamped)-> Result<(), ()>;
}
