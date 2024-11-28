use crate::tecs_ex_ctrl::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{s_hello2::*, t_bob::*};

pub struct TAlice<'a, T, U>
where
	T: SHello2,
	U: SHello2,
{
	c_bob: &'a T,
	c_bob2: &'a U,
	id: i32,
	variable: &'a SyncTAliceVar,
	ex_ctrl_ref: &'a TECSSemaphoreRef<'a>,
}

pub struct TAliceVar{
	pub count: i32,
}

pub struct SyncTAliceVar{
	unsafe_var: UnsafeCell<TAliceVar>,
}

unsafe impl Sync for SyncTAliceVar {}

pub struct EAlice1ForTAlice<'a>{
	pub cell: &'a TAlice<'a, EBob1ForTBob<'a>, EBob1ForTBob<'a>>,
}

pub struct EAlice2ForTAlice<'a>{
	pub cell: &'a TAlice<'a, EBob1ForTBob<'a>, EBob1ForTBob<'a>>,
}

pub struct LockGuardForTAlice<'a>{
	ex_ctrl_ref: &'a TECSSemaphoreRef<'a>,
}

#[link_section = ".rodata"]
pub static ALICE: TAlice<EBob1ForTBob, EBob1ForTBob> = TAlice {
	c_bob: &EBOB1FORBOB,
	c_bob2: &EBOB1FORBOB2,
	id: 0,
	variable: &ALICEVAR,
	ex_ctrl_ref: &ALICE_EX_CTRL_REF,
};

pub static ALICEVAR: SyncTAliceVar = SyncTAliceVar {
	/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the semaphore object.
	unsafe_var: UnsafeCell::new(TAliceVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static ALICE_EX_CTRL_REF: TECSSemaphoreRef = TECSSemaphoreRef{
	inner: unsafe{SemaphoreRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_1).unwrap())},
};

#[link_section = ".rodata"]
pub static EALICE1FORALICE: EAlice1ForTAlice = EAlice1ForTAlice {
	cell: &ALICE,
};

#[link_section = ".rodata"]
pub static EALICE2FORALICE: EAlice2ForTAlice = EAlice2ForTAlice {
	cell: &ALICE,
};

impl Drop for LockGuardForTAlice {
	fn drop(&mut self){
		self.ex_ctrl_ref.unlock();
	}
}

impl<T: SHello2, U: SHello2> TAlice<'_, T, U> {
	pub fn get_cell_ref(&'static self) -> (&'static T, &'static U, &'static i32, &'static mut TAliceVar, LockGuardForTAlice) {
		self.ex_ctrl_ref.lock();
		(
			self.c_bob,
			self.c_bob2,
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			LockGuardForTAlice{
				ex_ctrl_ref: self.ex_ctrl_ref,
			}
		)
	}
}
