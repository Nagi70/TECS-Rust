use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
use crate::{s_manage::*, t_manager::*, s_motor::*, t_motor::*};

pub struct TTaskbody1<'a, T, U>
where
	T: SManage,
	U: SMotor,
{
	c_manager: &'a T,
	c_motor: &'a U,
	variable: SyncTTaskbody1Var,
}

pub struct TTaskbody1Var{
	pub speed: i32,
}

pub struct SyncTTaskbody1Var{
	unsafe_var: UnsafeCell<TTaskbody1Var>,
}

unsafe impl Sync for SyncTTaskbody1Var {}

pub struct ETaskbodyForTTaskbody1<'a>{
	pub cell: &'a TTaskbody1<'a, EManage2ForTManager<'a>, EMotorForTMotor<'a>>,
}

#[link_section = ".rodata"]
pub static TASKBODY1: TTaskbody1<EManage2ForTManager, EMotorForTMotor> = TTaskbody1 {
	c_manager: &EMANAGE2FORMANAGER,
	c_motor: &EMOTORFORMOTOR2,
	variable: &TASKBODY1VAR,
};

pub static TASKBODY1VAR: SyncTTaskbody1Var = SyncTTaskbody1Var {
	unsafe_var: UnsafeCell::new(TTaskbody1Var {
		speed: 0,
	}),
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY1: ETaskbodyForTTaskbody1 = ETaskbodyForTTaskbody1 {
	cell: &TASKBODY1,
};

impl<T: SManage, U: SMotor> TTaskbody1<'_, T, U> {
	pub fn get_cell_ref(&'static self) -> (&T, &U, &mut TTaskbody1Var, &TECSDummyLockGuard) {
		(
			self.c_manager,
			self.c_motor,
			unsafe{&mut *self.variable.unsafe_var.get()},
			&DUMMY_LOCK_GUARD
		)
	}
}
