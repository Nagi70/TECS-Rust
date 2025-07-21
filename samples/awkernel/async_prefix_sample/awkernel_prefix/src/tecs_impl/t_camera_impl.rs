use crate::tecs_signature::t_camera::*;
use crate::tecs_signature::{s_camera_info::*, s_camerabody::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SCamerabody for ECameraForTCamera<'_>{

	fn main(&'static self, camera_info: &mut u32) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

