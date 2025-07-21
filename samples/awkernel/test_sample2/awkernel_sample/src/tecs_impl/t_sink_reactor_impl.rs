use crate::tecs_signature::t_sink_reactor::*;
use crate::{s_sink_reactorbody::*, s_pubsub::*, s_task::*};
impl STask for ETaskForTSinkReactor<'_>{

	fn temp(&'static self) {
		let lg = self.cell.get_cell_ref();

	}
}

