use spin::Mutex;
use crate::{t_motor::*, s_powerdown::*, s_motor::*};

impl SMotor for EMotorForTMotor<'_>{

	#[inline]
	fn set_motor_ref(&self) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

        let motor_ptr = unsafe { pup_motor_get_device(*port) };
        if motor_ptr == core::ptr::null_mut() {
			c_powerdown.powerdown(&pbio_error_t::PBIO_ERROR_NO_DEV);
        }
		var.lock().motor = Some(unsafe { &mut *motor_ptr });

	}
	#[inline]
	fn setup(&self, positive_direction: &pup_direction_t, reset_count: &bool) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

		c_powerdown.powerdown( unsafe { &pup_motor_setup(var.lock().motor.as_mut().unwrap(), *positive_direction, *reset_count) });

	}
	#[inline]
	fn set_speed(&self, speed: &i32) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

		c_powerdown.powerdown( unsafe { &pup_motor_set_speed(var.lock().motor.as_mut().unwrap(), *speed) });

	}
	#[inline]
	fn stop(&self) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

		c_powerdown.powerdown( unsafe { &pup_motor_stop(var.lock().motor.as_mut().unwrap()) });

	}
}

