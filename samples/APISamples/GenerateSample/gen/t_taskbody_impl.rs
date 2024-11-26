use crate::{t_taskbody::*, s_task_body::*, s_motor::*, s_sensor::*};

impl STaskBody for ETaskbodyForTTaskbody<'_>{

	fn main(&'static self) {
		let (c_motor_a, c_motor_b, c_sensor) = self.cell.get_cell_ref();

	}
}

