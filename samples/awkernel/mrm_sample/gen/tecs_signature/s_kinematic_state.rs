use crate::tecs_struct_def::*;
pub trait SKinematicState {
	fn send(&'static self, kinematic_state: &KinematicState);
}
