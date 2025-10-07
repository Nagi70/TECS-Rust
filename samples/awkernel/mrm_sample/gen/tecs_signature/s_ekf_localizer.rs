use crate::tecs_global::*;
pub trait SEkfLocalizer {
	fn main(&'static self, twist: &TwistWithCovarianceStamped);
}
