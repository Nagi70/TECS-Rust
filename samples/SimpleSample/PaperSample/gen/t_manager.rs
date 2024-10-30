use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
use crate::{s_motor::*, t_motor::*};

pub struct TManager<'a, T>
where
	T: SMotor,
{
	c_motor: &'a T,
	variable: SyncTManagerVar,
	mutex_ref: &'a TECSMutexRef<'a>,
}

pub struct TManagerVar{
	pub task_id: i32,
}

pub struct SyncTManagerVar{
	unsafe_var: UnsafeCell<TManagerVar>,
}

unsafe impl Sync for SyncTManagerVar {}

pub struct EManage1ForTManager<'a>{
	pub cell: &'a TManager<'a, EMotorForTMotor<'a>>,
}

pub struct EManage2ForTManager<'a>{
	pub cell: &'a TManager<'a, EMotorForTMotor<'a>>,
}

pub struct LockGuardForTManager<'a>{
	mutex_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
pub static MANAGER: TManager<EMotorForTMotor> = TManager {
	c_motor: &EMOTORFORMOTOR1,
	variable: &MANAGERVAR,
	mutex_ref: &MANAGER_MUTEX_REF,
};

pub static MANAGERVAR: SyncTManagerVar = SyncTManagerVar {
	unsafe_var: UnsafeCell::new(TManagerVar {
		task_id: 0,
	}),
};

#[link_section = ".rodata"]
pub static MANAGER_MUTEX_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZero::new(TECS_RUST_MUTEX_1).unwrap())},
};

#[link_section = ".rodata"]
pub static EMANAGE1FORMANAGER: EManage1ForTManager = EManage1ForTManager {
	cell: &MANAGER,
};

#[link_section = ".rodata"]
pub static EMANAGE2FORMANAGER: EManage2ForTManager = EManage2ForTManager {
	cell: &MANAGER,
};

impl Drop for LockGuardForTManager {
	fn drop(&mut self){
		self.mutex_ref.unlock();
	}
}

impl<T: SMotor> TManager<'_, T> {
	pub fn get_cell_ref(&'static self) -> (&T, &mut TManagerVar, LockGuardForTManager) {
		self.mutex_ref.lock();
		(
			self.c_motor,
			unsafe{&mut *self.variable.unsafe_var.get()},
			LockGuardForTManager{
				mutex_ref: self.mutex_ref,
			}
		)
	}
}
