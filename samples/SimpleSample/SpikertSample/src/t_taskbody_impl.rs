use crate::{t_taskbody::*, s_task_body::*, s_sensor::*, s_motor::*};

impl STaskBody for ETaskbodyForTTaskbody<'_>{

	#[inline]
	fn main(&self) {
		let (c_sensor, c_motor) = self.cell.get_cell_ref();

		c_sensor.set_device_ref();

		let reset_count = true;
		c_motor.setup(&pbio_direction_t::PBIO_DIRECTION_CLOCKWISE, &reset_count);

		let mut dist = 0;
		loop{
			c_sensor.get_distance(&mut dist);
			if dist >= 0{
				if dist <= 50{
					print!("Detect Objects (distance = %d mm).", dist);
					c_sensor.light_on();
					c_motor.stop();
				}else if dist <= 75{
					print!("Detect Objects (distance = %d mm).", dist);
					c_sensor.light_set(&100, &100, &100, &0);
					c_motor.set_speed(&300);
				}else if dist <= 100{
					print!("Detect Objects (distance = %d mm).", dist);
					c_sensor.light_set(&100, &100, &0, &0);
					c_motor.set_speed(&300);
				}else {
					print!("Detect Objects (distance = %d mm).", dist);
					c_sensor.light_set(&100, &0, &0, &0);
					c_motor.set_speed(&300);
				}
			}else {
				print!("No Object",);
				c_sensor.light_off();
				c_motor.stop();
			}
		}
	}
}

