use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
use crate::{s_hello2::*, t_bob::*};

pub struct TAlice<'a, T, U>
where
	T: SHello2,
	U: SHello2,
{
	c_bob: &'a T,
	c_bob2: &'a U,
	id: i32,
	variable: SyncTAliceVar,
	mutex_ref: &'a TECSMutexRef<'a>,
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
	mutex_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
pub static ALICE: TAlice<EBob1ForTBob, EBob1ForTBob> = TAlice {
	c_bob: &EBOB1FORBOB,
	c_bob2: &EBOB1FORBOB2,
	id: 0,
	variable: &ALICEVAR,
	mutex_ref: &ALICE_MUTEX_REF,
};

pub static ALICEVAR: SyncTAliceVar = SyncTAliceVar {
	unsafe_var: UnsafeCell::new(TAliceVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static ALICE_MUTEX_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZero::new(TECS_RUST_MUTEX_1).unwrap())},
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
		self.mutex_ref.unlock();
	}
}

impl<T: SHello2, U: SHello2> TAlice<'_, T, U> {
	pub fn get_cell_ref(&'static self) -> (&T, &U, &i32, &mut TAliceVar, LockGuardForTAlice) {
		self.mutex_ref.lock();
		(
			self.c_bob,
			self.c_bob2,
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			LockGuardForTAlice{
				mutex_ref: self.mutex_ref,
			}
		)
	}
}
