use crate::tecs_struct_def::*;
pub trait SEkfLocalizer {
	fn main(&'static self, twist: &TwistWithCovarianceStamped);
}
