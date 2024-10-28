use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
use crate::{s_hello::*, t_alice::*};

pub struct TAlice<'a, T>
where
	T: SHello,
{
	c_person: &'a T,
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
	pub cell: &'a TAlice<'a, EAlice3ForTAlice<'a>>,
}

pub struct EAlice2ForTAlice<'a>{
	pub cell: &'a TAlice<'a, EAlice3ForTAlice<'a>>,
}

pub struct EAlice3ForTAlice<'a>{
	pub cell: &'a TAlice<'a, EAlice3ForTAlice<'a>>,
}

pub struct LockGuardForTAlice<'a>{
	mutex_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
pub static ALICE1: TAlice<EAlice3ForTAlice> = TAlice {
	c_person: &EALICE3FORALICE2,
	id: 0,
	variable: &ALICE1VAR,
	mutex_ref: &ALICE1_MUTEX_REF,
};

pub static ALICE1VAR: SyncTAliceVar = SyncTAliceVar {
	unsafe_var: UnsafeCell::new(TAliceVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static ALICE1_MUTEX_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZero::new(TECS_RUST_MUTEX_1).unwrap())},
};

#[link_section = ".rodata"]
pub static EALICE1FORALICE1: EAlice1ForTAlice = EAlice1ForTAlice {
	cell: &ALICE1,
};

#[link_section = ".rodata"]
pub static EALICE2FORALICE1: EAlice2ForTAlice = EAlice2ForTAlice {
	cell: &ALICE1,
};

#[link_section = ".rodata"]
pub static EALICE3FORALICE1: EAlice3ForTAlice = EAlice3ForTAlice {
	cell: &ALICE1,
};

#[link_section = ".rodata"]
pub static ALICE2: TAlice<EAlice3ForTAlice> = TAlice {
	c_person: &EALICE3FORALICE1,
	id: 0,
	variable: &ALICE2VAR,
	mutex_ref: &ALICE2_MUTEX_REF,
};

pub static ALICE2VAR: SyncTAliceVar = SyncTAliceVar {
	unsafe_var: UnsafeCell::new(TAliceVar {
		count: 0,
	}),
};

#[link_section = ".rodata"]
pub static ALICE2_MUTEX_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZero::new(TECS_RUST_MUTEX_2).unwrap())},
};

#[link_section = ".rodata"]
pub static EALICE1FORALICE2: EAlice1ForTAlice = EAlice1ForTAlice {
	cell: &ALICE2,
};

#[link_section = ".rodata"]
pub static EALICE2FORALICE2: EAlice2ForTAlice = EAlice2ForTAlice {
	cell: &ALICE2,
};

#[link_section = ".rodata"]
pub static EALICE3FORALICE2: EAlice3ForTAlice = EAlice3ForTAlice {
	cell: &ALICE2,
};

impl Drop for LockGuardForTAlice {
	fn drop(&mut self){
		self.mutex_ref.unlock();
	}
}

impl<T: SHello> TAlice<'_, T> {
	pub fn get_cell_ref(&'static self) -> (&T, &i32, &mut TAliceVar, LockGuardForTAlice) {
		self.mutex_ref.lock();
		(
			self.c_person,
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			LockGuardForTAlice{
				mutex_ref: self.mutex_ref,
			}
		)
	}
}
