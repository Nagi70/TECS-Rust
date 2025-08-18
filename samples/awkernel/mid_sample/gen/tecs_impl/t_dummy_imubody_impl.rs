use crate::tecs_signature::t_dummy_imubody::*;
use crate::tecs_signature::{s_imu::*, s_dummy_imubody::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SDummyImubody for EDummyImubodyForTDummyImubody<'_>{

	fn main(&'static self, imu: &mut Frame) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

