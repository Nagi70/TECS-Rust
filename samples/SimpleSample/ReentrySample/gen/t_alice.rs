use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
use crate::{s_hello::*, t_bob::*};

pub struct TAlice<'a, T>
where
	T: SHello,
{
	c_bob: &'a T,
	id: i32,
	variable SyncTAliceVar,
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
	pub cell: &'a TAlice<'a, EBobForTBob<'a>>,
}

pub struct EAlice2ForTAlice<'a>{
	pub cell: &'a TAlice<'a, EBobForTBob<'a>>,
}

pub struct EAlice3ForTAlice<'a>{
	pub cell: &'a TAlice<'a, EBobForTBob<'a>>,
}

pub struct MutexGuardForTAlice<'a>{
	mutex_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
pub static ALICE: TAlice<EBobForTBob> = TAlice {
	c_bob: &EBOBFORBOB,
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

#[link_section = ".rodata"]
pub static EALICE3FORALICE: EAlice3ForTAlice = EAlice3ForTAlice {
	cell: &ALICE,
};

impl Drop for MutexGuardForTAlice {
	fn drop(&mut self){
		self.mutex_ref.unlock();
	}
}

impl<T: SHello> TAlice<'_, T> {
	pub fn get_cell_ref(&'static self) -> (&T, &i32, &mut TAliceVar, MutexGuardForTAlice) {
		self.mutex_ref.lock();
		(
			self.c_bob,
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			MutexGuardForTAlice{
				mutex_ref: self.mutex_ref,
			}
		)
	}
}
