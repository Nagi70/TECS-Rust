use crate::{t_taskbody::*, s_task_body::*, s_sensor::*, s_motor::*};

impl STaskBody for ETaskbodyForTTaskbody<'_>{

	#[inline]
	fn main(&self) {
		let (c_sensor, c_motor) = self.cell.get_cell_ref();

	}
}

