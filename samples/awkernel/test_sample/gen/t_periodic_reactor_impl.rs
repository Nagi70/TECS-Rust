use crate::{t_periodic_reactor::*, s_periodic_reactorbody::*, s_pubsub::*, s_task::*};

impl STask for ETaskForTPeriodicReactor<'_>{

	fn temp(&'static self) {
		let lg = self.cell.get_cell_ref();

	}
}

