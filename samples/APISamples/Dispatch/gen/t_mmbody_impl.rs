use crate::{t_mmbody::*, s_motor::*, s_task_body::*};

impl STaskBody for EMmbodyForTMmbody<'_>{

	fn main(&'static self) {
		let (c_motor1, c_motor2) = self.cell.get_cell_ref();

	}
}

