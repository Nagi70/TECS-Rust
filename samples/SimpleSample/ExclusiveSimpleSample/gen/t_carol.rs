use crate::tecs_ex_ctrl::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
pub struct TCarol<'a>
{
	id: i32,
	variable: &'a SyncTCarolVar,
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

#[link_section = ".rodata"]
pub static CAROL: TCarol = TCarol {
	id: 1,
	variable: &CAROLVAR,
};

pub static CAROLVAR: SyncTCarolVar = SyncTCarolVar {
	/// This UnsafeCell is accessed by multiple tasks, but is secure because it is accessed exclusively, with exclusive control applied to the component closest to root.
	unsafe_var: UnsafeCell::new(TCarolVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static ECAROLFORCAROL: ECarolForTCarol = ECarolForTCarol {
	cell: &CAROL,
};

#[link_section = ".rodata"]
pub static CAROL2: TCarol = TCarol {
	id: 2,
	variable: &CAROL2VAR,
};

pub static CAROL2VAR: SyncTCarolVar = SyncTCarolVar {
	/// This UnsafeCell is accessed by multiple tasks, but is secure because it is accessed exclusively, with exclusive control applied to the component closest to root.
	unsafe_var: UnsafeCell::new(TCarolVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static ECAROLFORCAROL2: ECarolForTCarol = ECarolForTCarol {
	cell: &CAROL2,
};

impl<> TCarol<'_> {
	pub fn get_cell_ref(&'static self) -> (&'static i32, &'static mut TCarolVar, &TECSDummyLockGuard) {
		(
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			&DUMMY_LOCK_GUARD
		)
	}
}
