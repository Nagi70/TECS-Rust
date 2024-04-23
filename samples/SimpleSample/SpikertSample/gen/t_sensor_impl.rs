use spin::Mutex;
use crate::{t_sensor::*, s_powerdown::*, s_sensor::*};

impl SSensor for ESensorForTSensor<'_>{

	#[inline]
	fn set_device_ref(&self) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

	}
	#[inline]
	fn get_distance(&self, distance: &mut i32) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

	}
	#[inline]
	fn light_on(&self) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

	}
	#[inline]
	fn light_set(&self, bv1: &i32, bv2: &i32, bv3: &i32, bv4: &i32) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

	}
	#[inline]
	fn light_off(&self) {
		let (c_powerdown, port, var) = self.cell.get_cell_ref();

	}
}

