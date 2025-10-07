use crate::tecs_global::*;
pub trait SEkfLocalizerTimer {
	fn main(&'static self, kinematic_state: &mut KinematicState);
}
