use crate::tecs_signature::t_dummy_imu::*;
use crate::tecs_signature::{s_dummy_imubody::*, s_reactorbody::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SReactorbody for EDummyImuForTDummyImu<'_>{

	fn main(&'static self) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

