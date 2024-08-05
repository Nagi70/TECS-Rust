use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
use crate::{s_hello::*, t_carol::*};

pub struct TBob<'a, T>
where
	T: SHello,
{
	c_carol: &'a T,
	id: i32,
	variable SyncTBobVar,
}

pub struct TBobVar{
	pub count: i32,
}

pub struct SyncTBobVar{
	unsafe_var: UnsafeCell<TBobVar>,
}

unsafe impl Sync for SyncTBobVar {}

pub struct EBobForTBob<'a>{
	pub cell: &'a TBob<'a, ECarolForTCarol<'a>>,
}

#[link_section = ".rodata"]
pub static BOB: TBob<ECarolForTCarol> = TBob {
	c_carol: &ECAROLFORCAROL2,
	id: 0,
	variable: &BOBVAR,
};

pub static BOBVAR: SyncTBobVar = SyncTBobVar {
	unsafe_var: UnsafeCell::new(TBobVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static EBOBFORBOB: EBobForTBob = EBobForTBob {
	cell: &BOB,
};

impl<T: SHello> TBob<'_, T> {
	pub fn get_cell_ref(&'static self) -> (&T, &i32, &mut TBobVar, &TECSDummyMutexGuard) {
		(
			self.c_carol,
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			&DUMMY_MUTEX_GUARD
		)
	}
}
