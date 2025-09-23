use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_dummy_imubody::*;
use crate::tecs_signature::{s_imu::*, s_dummy_imubody::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SDummyImubody for EReactorForTDummyImubody<'_>{

	fn main(&'static self, imu: &mut ImuMsg) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

