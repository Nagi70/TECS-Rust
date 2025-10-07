use crate::tecs_global::*;
pub trait SKinematicState {
	fn send(&'static self, kinematic_state: &KinematicState);
}
