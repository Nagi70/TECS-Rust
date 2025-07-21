use crate::tecs_signature::t_camerabody::*;
use crate::tecs_signature::{s_reactorbody::*, s_camerabody::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SReactorbody for ECamerabodyForTCamerabody<'_>{

	fn main(&'static self) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

