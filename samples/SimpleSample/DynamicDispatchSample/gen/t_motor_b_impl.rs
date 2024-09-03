use spin::Mutex;
use crate::{t_motor_b::*, s_motor::*};

impl SMotor for EMotorForTMotorB<'_>{

	#[inline]
	fn set_motor_ref(&self) {
		let (port, var) = self.cell.get_cell_ref();

	}
	#[inline]
	fn setup(&self, positive_direction: &pup_direction_t, reset_count: &bool) {
		let (port, var) = self.cell.get_cell_ref();

	}
	#[inline]
	fn set_speed(&self, speed: &i32) {
		let (port, var) = self.cell.get_cell_ref();

	}
	#[inline]
	fn stop(&self) {
		let (port, var) = self.cell.get_cell_ref();

	}
}

