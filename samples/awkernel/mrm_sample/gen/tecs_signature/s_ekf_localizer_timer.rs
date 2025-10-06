use crate::tecs_struct_def::*;
pub trait SEkfLocalizerTimer {
	fn main(&'static self, kinematic_state: &mut KinematicState);
}
