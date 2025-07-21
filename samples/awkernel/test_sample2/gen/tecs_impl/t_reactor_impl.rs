use crate::tecs_signature::t_reactor::*;
use crate::{s_reactorbody::*, s_pubsub::*, s_task::*};
impl STask for ETaskForTReactor<'_>{

	fn temp(&'static self) {
		let lg = self.cell.get_cell_ref();

	}
}

