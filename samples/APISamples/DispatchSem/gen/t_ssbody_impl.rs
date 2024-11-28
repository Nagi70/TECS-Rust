use crate::{t_ssbody::*, s_sensor::*, s_task_body::*};

impl STaskBody for ESsbodyForTSsbody<'_>{

	fn main(&'static self) {
		let (c_sensor1, c_sensor2) = self.cell.get_cell_ref();

	}
}

