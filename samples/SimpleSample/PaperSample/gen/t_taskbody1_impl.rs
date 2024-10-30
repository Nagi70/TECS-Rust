use spin::Mutex;
use crate::{t_taskbody1::*, s_task_body::*, s_manage::*, s_motor::*};

impl STaskBody for ETaskbodyForTTaskbody1<'_>{

	fn main(&'static self) {
		let (c_manager, c_motor, var, _lg) = self.cell.get_cell_ref();

	}
}

