use crate::tecs_global::*;
use crate::tecs_celltype::t_array::*;
use crate::tecs_signature::s_array::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SArray for EArrayForTArray<'_>{

	fn main(&'static self) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

