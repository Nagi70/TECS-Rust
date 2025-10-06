use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_stop_filter::*;
use crate::tecs_signature::{s_kinematic_state::*, s_stop_filter::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SKinematicState for EKinematicStateForTStopFilter<'_>{

	fn send(&'static self, kinematic_state: &KinematicState) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl SStopFilter for EReactorForTStopFilter<'_>{

	fn main(&'static self, odom_in: &KinematicState, odom_out: &mut KinematicState) {
		let mut lg = self.cell.get_cell_ref();

	}
}

