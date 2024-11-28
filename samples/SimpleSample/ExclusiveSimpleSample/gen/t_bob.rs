use crate::tecs_ex_ctrl::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{s_hello3::*, t_carol::*};

pub struct TBob<'a, T>
where
	T: SHello3,
{
	c_carol: &'a T,
	id: i32,
	variable: &'a SyncTBobVar,
	ex_ctrl_ref: &'a (dyn LockManager + Sync + Send),
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

pub struct LockGuardForTBob<'a>{
	ex_ctrl_ref: &'a (dyn LockManager + Sync + Send),
}

#[link_section = ".rodata"]
pub static BOB: TBob<ECarolForTCarol> = TBob {
	c_carol: &ECAROLFORCAROL,
	id: 1,
	variable: &BOBVAR,
	ex_ctrl_ref: &DUMMY_EX_CTRL_REF,
};

pub static BOBVAR: SyncTBobVar = SyncTBobVar {
	/// This UnsafeCell is accessed by multiple tasks, but is secure because it is accessed exclusively, with exclusive control applied to the component closest to root.
	unsafe_var: UnsafeCell::new(TBobVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static EBOB1FORBOB: EBob1ForTBob = EBob1ForTBob {
	cell: &BOB,
};

#[link_section = ".rodata"]
pub static EBOB2FORBOB: EBob2ForTBob = EBob2ForTBob {
	cell: &BOB,
};

#[link_section = ".rodata"]
pub static BOB2: TBob<ECarolForTCarol> = TBob {
	c_carol: &ECAROLFORCAROL2,
	id: 2,
	variable: &BOB2VAR,
	ex_ctrl_ref: &BOB2_EX_CTRL_REF,
};

pub static BOB2VAR: SyncTBobVar = SyncTBobVar {
	/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the semaphore object.
	unsafe_var: UnsafeCell::new(TBobVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static BOB2_EX_CTRL_REF: TECSSemaphoreRef = TECSSemaphoreRef{
	inner: unsafe{SemaphoreRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_2).unwrap())},
};

#[link_section = ".rodata"]
pub static EBOB1FORBOB2: EBob1ForTBob = EBob1ForTBob {
	cell: &BOB2,
};

#[link_section = ".rodata"]
pub static EBOB2FORBOB2: EBob2ForTBob = EBob2ForTBob {
	cell: &BOB2,
};

impl Drop for LockGuardForTBob {
	fn drop(&mut self){
		self.ex_ctrl_ref.unlock();
	}
}

impl<T: SHello3> TBob<'_, T> {
	pub fn get_cell_ref(&'static self) -> (&'static T, &'static i32, &'static mut TBobVar, LockGuardForTBob) {
		self.ex_ctrl_ref.lock();
		(
			self.c_carol,
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			LockGuardForTBob{
				ex_ctrl_ref: self.ex_ctrl_ref,
			}
		)
	}
}
