use spin::Mutex;
use crate::{t_sensor::*, s_sensor::*};

impl SSensor for ESensorForTSensor<'_>{

	#[inline]
	fn set_device_ref(&'static self) {
		let (port, var, _lg) = self.cell.get_cell_ref();

	}
	#[inline]
	fn get_distance(&'static self, distance: &mut i32) {
		let (port, var, _lg) = self.cell.get_cell_ref();

	}
	#[inline]
	fn light_on(&'static self) {
		let (port, var, _lg) = self.cell.get_cell_ref();

	}
	#[inline]
	fn light_set(&'static self, bv1: &i32, bv2: &i32, bv3: &i32, bv4: &i32) {
		let (port, var, _lg) = self.cell.get_cell_ref();

	}
	#[inline]
	fn light_off(&'static self) {
		let (port, var, _lg) = self.cell.get_cell_ref();

	}
}

