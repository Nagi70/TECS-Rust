use crate::tecs_struct_def::*;
pub trait STwist2Accel {
	fn main(&'static self, twist: &KinematicState, accel: &mut AccelWithCovarianceStamped);
}
