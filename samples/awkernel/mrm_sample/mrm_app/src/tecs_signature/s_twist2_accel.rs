use crate::tecs_global::*;
pub trait STwist2Accel {
	fn main(&'static self, twist: &KinematicState, accel: &mut AccelWithCovarianceStamped);
}
