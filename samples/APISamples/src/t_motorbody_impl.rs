use crate::{t_motorbody::*, s_motor::*, s_task_body::*};

impl STaskBody for EMotorbodyForTMotorbody<'_>{

	fn main(&'static self) {
		let c_motor = self.cell.get_cell_ref();

		c_motor.set_motor_ref();
	}
}

