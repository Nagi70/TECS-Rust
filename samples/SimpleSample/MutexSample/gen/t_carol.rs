use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
pub struct TCarol<'a>
{
	id: i32,
	variable SyncTCarolVar,
	mutex_ref: &'a (dyn LockableForMutex + Sync + Send),
}

pub struct TCarolVar{
	pub count: i32,
}

pub struct SyncTCarolVar{
	unsafe_var: UnsafeCell<TCarolVar>,
}

unsafe impl Sync for SyncTCarolVar {}

pub struct ECarolForTCarol<'a>{
	pub cell: &'a TCarol<'a>,
}

pub struct MutexGuardForTCarol<'a>{
	mutex_ref: &'a (dyn LockableForMutex + Sync + Send),
}

#[link_section = ".rodata"]
pub static CAROL1: TCarol = TCarol {
	id: 1,
	variable: &CAROL1VAR,
	mutex_ref: &CAROL1_MUTEX_REF,
};

pub static CAROL1VAR: SyncTCarolVar = SyncTCarolVar {
	unsafe_var: UnsafeCell::new(TCarolVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static CAROL1_MUTEX_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZero::new(TECS_RUST_MUTEX_2).unwrap())},
};

#[link_section = ".rodata"]
pub static ECAROLFORCAROL1: ECarolForTCarol = ECarolForTCarol {
	cell: &CAROL1,
};

#[link_section = ".rodata"]
pub static CAROL2: TCarol = TCarol {
	id: 2,
	variable: &CAROL2VAR,
	mutex_ref: &DUMMY_MUTEX_REF,
};

pub static CAROL2VAR: SyncTCarolVar = SyncTCarolVar {
	unsafe_var: UnsafeCell::new(TCarolVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static ECAROLFORCAROL2: ECarolForTCarol = ECarolForTCarol {
	cell: &CAROL2,
};

impl Drop for MutexGuardForTCarol {
	fn drop(&mut self){
		self.mutex_ref.unlock();
	}
}

impl TCarol<'_> {
	pub fn get_cell_ref(&'static self) -> (&i32, &mut TCarolVar, MutexGuardForTCarol) {
		self.mutex_ref.lock();
		(
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			MutexGuardForTCarol{
				mutex_ref: self.mutex_ref,
			}
		)
	}
}
