use crate::tecs_struct_def::*;
pub trait STwistWithCovarianceSet {
	fn push(&'static self, twist: &TwistWithCovarianceStamped)-> Result<(), ()>;
}
