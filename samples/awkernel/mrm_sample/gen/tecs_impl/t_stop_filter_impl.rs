use crate::tecs_global::*;
use crate::tecs_celltype::t_stop_filter::*;
use crate::tecs_signature::{s_kinematic_state::*, s_stop_filter::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SKinematicState for EKinematicStateForTStopFilter{

	fn send(&'static self, kinematic_state: &KinematicState) {

	}
}

impl SStopFilter for EReactorForTStopFilter{

	fn main(&'static self, odom_in: &KinematicState, odom_out: &mut KinematicState) {

	}
}

