use crate::tecs_global::*;
use crate::tecs_celltype::t_twist2_accel::*;
use crate::tecs_signature::{s_accel_with_covariance_stamped::*, s_kinematic_state::*, s_twist2_accel::*, s_lowpass1d::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SKinematicState for EKinematicStateForTTwist2Accel{

	fn send(&'static self, kinematic_state: &KinematicState) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

impl STwist2Accel for EReactorForTTwist2Accel{

	fn main(&'static self, twist: &KinematicState, accel: &mut AccelWithCovarianceStamped) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

