use crate::tecs_signature::t_imu_driver::*;
use crate::tecs_signature::{s_imu_driverbody::*, s_reactorbody::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SReactorbody for EImuDriverForTImuDriver<'_>{

	fn main(&'static self) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

