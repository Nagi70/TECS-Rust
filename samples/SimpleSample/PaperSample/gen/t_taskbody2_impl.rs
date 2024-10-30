use spin::Mutex;
use crate::{t_taskbody2::*, s_task_body::*, s_sensor::*, s_motor::*};

impl STaskBody for ETaskbodyForTTaskbody2<'_>{

	fn main(&'static self) {
		let (c_sensor, c_motor, var, _lg) = self.cell.get_cell_ref();

	}
}

