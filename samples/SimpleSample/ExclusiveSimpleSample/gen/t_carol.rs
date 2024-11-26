use itron::mutex::MutexRef;
use crate::tecs_mutex::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
pub struct TCarol<'a>
{
	id: i32,
	variable: &'a SyncTCarolVar,
	mutex_ref: &'a TECSMutexRef<'a>,
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

pub struct LockGuardForTCarol<'a>{
	mutex_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
pub static CAROL: TCarol = TCarol {
	id: 1,
	variable: &CAROLVAR,
	mutex_ref: &CAROL_MUTEX_REF,
};

pub static CAROLVAR: SyncTCarolVar = SyncTCarolVar {
	unsafe_var: UnsafeCell::new(TCarolVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static CAROL_MUTEX_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_MUTEX_4).unwrap())},
};

#[link_section = ".rodata"]
pub static ECAROLFORCAROL: ECarolForTCarol = ECarolForTCarol {
	cell: &CAROL,
};

#[link_section = ".rodata"]
pub static CAROL2: TCarol = TCarol {
	id: 2,
	variable: &CAROL2VAR,
	mutex_ref: &CAROL2_MUTEX_REF,
};

pub static CAROL2VAR: SyncTCarolVar = SyncTCarolVar {
	unsafe_var: UnsafeCell::new(TCarolVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static CAROL2_MUTEX_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_MUTEX_5).unwrap())},
};

#[link_section = ".rodata"]
pub static ECAROLFORCAROL2: ECarolForTCarol = ECarolForTCarol {
	cell: &CAROL2,
};

impl Drop for LockGuardForTCarol {
	fn drop(&mut self){
		self.mutex_ref.unlock();
	}
}

impl<> TCarol<'_> {
	pub fn get_cell_ref(&'static self) -> (&'static i32, &'static mut TCarolVar, LockGuardForTCarol) {
		self.mutex_ref.lock();
		(
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			LockGuardForTCarol{
				mutex_ref: self.mutex_ref,
			}
		)
	}
}
