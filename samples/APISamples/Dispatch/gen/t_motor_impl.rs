use crate::{t_motor::*, s_motor::*};

impl SMotor for EMotorForTMotor<'_>{

	#[inline]
	fn set_motor_ref(&'static self) {
		let (port, var, _lg) = self.cell.get_cell_ref();

	}
	#[inline]
	fn setup(&'static self, positive_direction: &PbioDirectionT, reset_count: &bool) {
		let (port, var, _lg) = self.cell.get_cell_ref();

	}
	#[inline]
	fn set_speed(&'static self, speed: &i32) {
		let (port, var, _lg) = self.cell.get_cell_ref();

	}
	#[inline]
	fn stop(&'static self) {
		let (port, var, _lg) = self.cell.get_cell_ref();

	}
}

