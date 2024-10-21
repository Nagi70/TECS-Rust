use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
pub struct TCarol<'a>
{
	id: i32,
	variable: SyncTCarolVar,
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
	unsafe_var: UnsafeCell::new(TCarolVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static ECAROLFORCAROL2: ECarolForTCarol = ECarolForTCarol {
	cell: &CAROL2,
};

impl TCarol<'_> {
	pub fn get_cell_ref(&'static self) -> (&i32, &mut TCarolVar, &TECSDummyMutexGuard) {
		(
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			&DUMMY_MUTEX_GUARD
		)
	}
}
