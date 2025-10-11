use crate::tecs_global::*;
use crate::tecs_celltype::t_trajectory_follower::*;
use crate::tecs_signature::{s_kinematic_state::*, s_accel_with_covariance_stamped::*, s_control::*, s_trajectory_follower::*, s_utils_trajectory::*, s_utils_pose_deviation::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SKinematicState for EKinematicStateSfForTTrajectoryFollower{

	fn send(&'static self, kinematic_state: &KinematicState) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl SAccelWithCovarianceStamped for EAccelForTTrajectoryFollower{

	fn send(&'static self, accel_with_covariance: &AccelWithCovarianceStamped) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl STrajectoryFollower for EReactorForTTrajectoryFollower{

	fn main(&'static self, kinematic_state: &KinematicState, accel: &AccelWithCovarianceStamped, control: &mut Control) {
		let mut lg = self.cell.get_cell_ref();

	}
}

