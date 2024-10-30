use spin::Mutex;
use crate::{t_motor::*, s_motor::*};

impl SMotor for EMotorForTMotor<'_>{

	#[inline]
	fn set_motor_ref(&'static self) {
		let (port, var, _lg) = self.cell.get_cell_ref();
		let temp = 0;

	}
	#[inline]
	fn setup(&'static self, positive_direction: &pbio_direction_t, reset_count: &bool) {
		let (port, var, _lg) = self.cell.get_cell_ref();
		let temp = 0;

	}
	#[inline]
	fn set_speed(&'static self, speed: &i32) {
		let (port, var, _lg) = self.cell.get_cell_ref();
		let temp = 0;

	}
	#[inline]
	fn stop(&'static self) {
		let (port, var, _lg) = self.cell.get_cell_ref();
		let temp = 0;

	}
}

