use crate::{t_sink_reactor::*, s_sink_reactorbody::*, s_pubsub::*, s_task::*};

impl STask for ETaskForTSinkReactor<'_>{

	fn temp(&'static self) {
		let lg = self.cell.get_cell_ref();

	}
}

