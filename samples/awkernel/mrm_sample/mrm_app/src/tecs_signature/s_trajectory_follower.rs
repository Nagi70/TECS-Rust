use crate::tecs_global::*;
pub trait STrajectoryFollower {
	fn main(&'static self, kinematic_state: &KinematicState, accel: &AccelWithCovarianceStamped);
}
