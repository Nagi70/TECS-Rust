use spin::Mutex;
use crate::{t_motor::*, s_powerdown::*, s_motor::*};

impl SMotor for EMotorForTMotor<'_>{

	#[inline]
	fn set_motor_ref(&self) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

	}
	#[inline]
	fn setup(&self, positive_direction: &pbio_direction_t, reset_count: &bool) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

	}
	#[inline]
	fn set_speed(&self, speed: &i32) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

	}
	#[inline]
	fn stop(&self) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

	}
}

