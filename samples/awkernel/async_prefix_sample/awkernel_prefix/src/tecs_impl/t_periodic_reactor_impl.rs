use crate::tecs_signature::t_periodic_reactor::*;
use crate::tecs_signature::{s_reactorbody::*, s_task::*};
use awkernel_lib::sync::mutex::MCSNode;
impl STask for ETaskForTPeriodicReactor<'_>{

	fn temp(&'static self) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

