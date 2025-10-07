use crate::tecs_global::*;
use crate::tecs_celltype::t_trajectory_follower::*;
use crate::tecs_signature::{s_kinematic_state::*, s_accel_with_covariance_stamped::*, s_trajectory_follower::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SKinematicState for EKinematicStateSfForTTrajectoryFollower<'_>{

	fn send(&'static self, kinematic_state: &KinematicState) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl SAccelWithCovarianceStamped for EAccelForTTrajectoryFollower<'_>{

	fn send(&'static self, accel_with_covariance: &AccelWithCovarianceStamped) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl STrajectoryFollower for EReactorForTTrajectoryFollower<'_>{

	fn main(&'static self, kinematic_state: &KinematicState, accel: &AccelWithCovarianceStamped) {
		let mut lg = self.cell.get_cell_ref();

	}
}

