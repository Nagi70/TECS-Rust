use spin::Mutex;
use crate::{t_sensor::*, s_powerdown::*, s_sensor::*};

impl SSensor for ESensorForTSensor<'_>{

	#[inline]
	fn set_device_ref(&self) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

		let sensor_ptr = unsafe { pup_ultrasonic_sensor_get_device(*port) };
        if sensor_ptr == core::ptr::null_mut(){
			c_powerdown.powerdown(&pbio_error_t::PBIO_ERROR_NO_DEV);
        }
		var.lock().ult = Some(unsafe { &mut *sensor_ptr });

	}
	#[inline]
	fn get_distance(&self, distance: &mut i32) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

		*distance = unsafe { pup_ultrasonic_sensor_distance(var.lock().ult.as_mut().unwrap()) };

	}
	#[inline]
	fn light_on(&self) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

		c_powerdown.powerdown( unsafe { &pup_ultrasonic_sensor_light_on(var.lock().ult.as_mut().unwrap()) });

	}
	#[inline]
	fn light_set(&self, bv1: &i32, bv2: &i32, bv3: &i32, bv4: &i32) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

		c_powerdown.powerdown( unsafe { &pup_ultrasonic_sensor_light_set(var.lock().ult.as_mut().unwrap(), *bv1, *bv2, *bv3, *bv4) });

	}
	#[inline]
	fn light_off(&self) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

		c_powerdown.powerdown( unsafe { &pup_ultrasonic_sensor_light_off(var.lock().ult.as_mut().unwrap()) });

	}
}

