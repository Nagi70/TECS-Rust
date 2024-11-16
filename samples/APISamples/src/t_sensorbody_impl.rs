use crate::{t_sensorbody::*, s_sensor::*, s_task_body::*};

impl STaskBody for ESensorbodyForTSensorbody<'_>{

	fn main(&'static self) {
		let c_sensor = self.cell.get_cell_ref();

		c_sensor.set_device_ref();
	}
}

