use crate::tecs_signature::t_rate_bound_status::*;
use crate::tecs_signature::s_rate_monitor::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SRateMonitor for ERateForTRateBoundStatus<'_>{

	fn tick(&'static self) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

