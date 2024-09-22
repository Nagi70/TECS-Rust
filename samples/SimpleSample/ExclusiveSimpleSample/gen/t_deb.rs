use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
pub struct TDeb<'a>
{
	id: i32,
	variable SyncTDebVar,
	mutex_ref: &'a TECSMutexRef<'a>,
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

pub struct MutexGuardForTDeb<'a>{
	mutex_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
pub static DEB: TDeb = TDeb {
	id: 0,
	variable: &DEBVAR,
	mutex_ref: &DEB_MUTEX_REF,
};

pub static DEBVAR: SyncTDebVar = SyncTDebVar {
	unsafe_var: UnsafeCell::new(TDebVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static DEB_MUTEX_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZero::new(TECS_RUST_MUTEX_4).unwrap())},
};

#[link_section = ".rodata"]
pub static EDEBFORDEB: EDebForTDeb = EDebForTDeb {
	cell: &DEB,
};

impl Drop for MutexGuardForTDeb {
	fn drop(&mut self){
		self.mutex_ref.unlock();
	}
}

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
