use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
pub struct TDeb<'a>
{
	id: i32,
	variable SyncTDebVar,
}

pub struct TDebVar{
	pub count: i32,
}

pub struct SyncTDebVar{
	unsafe_var: UnsafeCell<TDebVar>,
}

unsafe impl Sync for SyncTDebVar {}

pub struct EDebForTDeb<'a>{
	pub cell: &'a TDeb<'a>,
}

#[link_section = ".rodata"]
pub static DEB: TDeb = TDeb {
	id: 0,
	variable: &DEBVAR,
};

pub static DEBVAR: SyncTDebVar = SyncTDebVar {
	unsafe_var: UnsafeCell::new(TDebVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static EDEBFORDEB: EDebForTDeb = EDebForTDeb {
	cell: &DEB,
};

impl TDeb<'_> {
	pub fn get_cell_ref(&'static self) -> (&i32, &mut TDebVar, &TECSDummyMutexGuard) {
		(
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			&DUMMY_MUTEX_GUARD
		)
	}
}
