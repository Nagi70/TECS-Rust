use crate::tecs_struct_def::*;
pub trait SStopFilter {
	fn main(&'static self, odom_in: &KinematicState, odom_out: &mut KinematicState);
}
