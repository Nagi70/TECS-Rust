use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
pub struct TDeb<'a>
{
	pub id: i32,
	variable SyncTDebVar,

	mutex_ref: &'a TECSDummyMutexRef,
}

pub struct TDebVar{
	pub count: i32,
}

pub struct SyncTDebVar{
	pub unsafe_var: UnsafeCell<TDebVar,
}

unsafe impl Sync for SyncTDebVar {}

pub struct EDebForTDeb<'a>{
	pub cell: &'a TDeb<'a>,
}

pub struct MutexGuardForTDeb<'a>{
	mutex_ref: &'a TECSDummyMutexRef,
}

#[link_section = ".rodata"]
pub static DEB: TDeb = TDeb {
	id: 0,
	variable: &DEBVAR,
	mutex_ref: &DUMMY_MUTEX_REF,
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
	pub fn get_cell_ref(&'static self) -> (&i32, &mut TDebVar, MutexGuardForTDeb) {
		self.mutex_ref.lock();
		(
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			MutexGuardForTDeb{
				mutex_ref: self.mutex_ref,
			}
		)
	}
}
