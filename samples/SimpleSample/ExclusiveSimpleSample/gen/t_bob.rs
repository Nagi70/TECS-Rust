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
	mutex_ref: &'a TECSMutexRef<'a>,
}

pub struct TBobVar{
	pub count: i32,
}

pub struct SyncTBobVar{
	unsafe_var: UnsafeCell<TBobVar>,
}

unsafe impl Sync for SyncTBobVar {}

pub struct EBob1ForTBob<'a>{
	pub cell: &'a TBob<'a, ECarolForTCarol<'a>>,
}

pub struct EBob2ForTBob<'a>{
	pub cell: &'a TBob<'a, ECarolForTCarol<'a>>,
}

pub struct MutexGuardForTBob<'a>{
	mutex_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
pub static BOB: TBob<ECarolForTCarol> = TBob {
	c_carol: &ECAROLFORCAROL,
	id: 0,
	variable: &BOBVAR,
	mutex_ref: &BOB_MUTEX_REF,
};

pub static BOBVAR: SyncTBobVar = SyncTBobVar {
	unsafe_var: UnsafeCell::new(TBobVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static BOB_MUTEX_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZero::new(TECS_RUST_MUTEX_2).unwrap())},
};

#[link_section = ".rodata"]
pub static EBOB1FORBOB: EBob1ForTBob = EBob1ForTBob {
	cell: &BOB,
};

#[link_section = ".rodata"]
pub static EBOB2FORBOB: EBob2ForTBob = EBob2ForTBob {
	cell: &BOB,
};

impl Drop for MutexGuardForTBob {
	fn drop(&mut self){
		self.mutex_ref.unlock();
	}
}

impl<T: SHello> TBob<'_, T> {
	pub fn get_cell_ref(&'static self) -> (&T, &i32, &mut TBobVar, MutexGuardForTBob) {
		self.mutex_ref.lock();
		(
			self.c_carol,
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			MutexGuardForTBob{
				mutex_ref: self.mutex_ref,
			}
		)
	}
}
