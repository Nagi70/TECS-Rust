use crate::tecs_global::*;
pub trait SStopFilter {
	fn main(&'static self, odom_in: &KinematicState, odom_out: &mut KinematicState);
}
