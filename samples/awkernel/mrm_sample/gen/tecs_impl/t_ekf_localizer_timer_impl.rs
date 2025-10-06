use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_ekf_localizer_timer::*;
use crate::tecs_signature::{s_kinematic_state::*, s_ekf_module::*, s_twist_with_covariance_get::*, s_ekf_localizer_timer::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SEkfLocalizerTimer for EReactorForTEkfLocalizerTimer<'_>{

	fn main(&'static self, kinematic_state: &mut KinematicState) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

