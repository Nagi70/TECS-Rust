use crate::tecs_struct_def::*;
pub trait STrajectoryFollower {
	fn main(&'static self, kinematic_state: &KinematicState, accel: &AccelWithCovarianceStamped);
}
