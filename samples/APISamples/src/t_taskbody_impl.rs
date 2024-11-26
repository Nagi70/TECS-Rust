use crate::{t_taskbody::*, s_task_body::*, s_motor::*, s_sensor::*};
use crate::{motor_t::*, device_t::*, error_t::*};
use crate::print;
use crate::tecs_print::*;
use itron::abi::*;

impl STaskBody for ETaskbodyForTTaskbody<'_>{

	fn main(&'static self) {
		let (c_motor_a, c_motor_b, c_sensor) = self.cell.get_cell_ref();

		c_motor_a.set_motor_ref();
		c_motor_b.set_motor_ref();
		c_sensor.set_device_ref();

		let reset_count = true;
		c_motor_a.setup(&PbioDirectionT::PbioDirectionClockwise, &reset_count);
		c_motor_b.setup(&PbioDirectionT::PbioDirectionClockwise, &reset_count);

		let mut dist = 0;
		loop{
			c_sensor.get_distance(&mut dist);
			if dist >= 0{
				if dist <= 50{
					print!("Detect Objects (distance = %d mm).", dist);
					c_sensor.light_on();
					c_motor_a.stop();
					c_motor_b.stop();
				}else if dist <= 75{
					print!("Detect Objects (distance = %d mm).", dist);
					c_sensor.light_set(&100, &100, &100, &0);
					c_motor_a.set_speed(&100);
					c_motor_b.set_speed(&100);
				}else if dist <= 100{
					print!("Detect Objects (distance = %d mm).", dist);
					c_sensor.light_set(&100, &100, &0, &0);
					c_motor_a.set_speed(&200);
					c_motor_b.set_speed(&200);
				}else {
					print!("Detect Objects (distance = %d mm).", dist);
					c_sensor.light_set(&100, &0, &0, &0);
					c_motor_a.set_speed(&300);
					c_motor_b.set_speed(&300);
				}
			}else {
				print!("No Object",);
				c_sensor.light_off();
				c_motor_a.stop();
				c_motor_b.stop();
			}
		}
	}
}

