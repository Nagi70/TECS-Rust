use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
use crate::{s_sensor::*, t_sensor::*, s_motor::*, t_motor::*};

pub struct TTaskbody2<'a, T, U>
where
	T: SSensor,
	U: SMotor,
{
	c_sensor: &'a T,
	c_motor: &'a U,
	variable: SyncTTaskbody2Var,
}

pub struct TTaskbody2Var{
	pub speed: i32,
	pub sensor_value: i32,
}

pub struct SyncTTaskbody2Var{
	unsafe_var: UnsafeCell<TTaskbody2Var>,
}

unsafe impl Sync for SyncTTaskbody2Var {}

pub struct ETaskbodyForTTaskbody2<'a>{
	pub cell: &'a TTaskbody2<'a, ESensorForTSensor<'a>, EMotorForTMotor<'a>>,
}

#[link_section = ".rodata"]
pub static TASKBODY2: TTaskbody2<ESensorForTSensor, EMotorForTMotor> = TTaskbody2 {
	c_sensor: &ESENSORFORSENSOR,
	c_motor: &EMOTORFORMOTOR2,
	variable: &TASKBODY2VAR,
};

pub static TASKBODY2VAR: SyncTTaskbody2Var = SyncTTaskbody2Var {
	unsafe_var: UnsafeCell::new(TTaskbody2Var {
		speed: 0,
		sensor_value: 0,
	}),
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY2: ETaskbodyForTTaskbody2 = ETaskbodyForTTaskbody2 {
	cell: &TASKBODY2,
};

impl<T: SSensor, U: SMotor> TTaskbody2<'_, T, U> {
	pub fn get_cell_ref(&'static self) -> (&T, &U, &mut TTaskbody2Var, &TECSDummyLockGuard) {
		(
			self.c_sensor,
			self.c_motor,
			unsafe{&mut *self.variable.unsafe_var.get()},
			&DUMMY_LOCK_GUARD
		)
	}
}
