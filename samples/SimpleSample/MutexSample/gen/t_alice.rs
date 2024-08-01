use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
use crate::{s_hello::*, t_deb::*, t_carol::*};

pub struct TAlice<'a>
{
	c_person: &'a (dyn SHello + Sync + Send),
	pub id: i32,
	variable SyncTAliceVar,

	mutex_ref: &'a (dyn LockableForMutex + Sync + Send),
}

pub struct TAliceVar{
	pub count: i32,
}

pub struct SyncTAliceVar{
	pub unsafe_var: UnsafeCell<TAliceVar,
}

unsafe impl Sync for SyncTAliceVar {}

pub struct EAlice1ForTAlice<'a>{
	pub cell: &'a TAlice<'a>,
}

pub struct EAlice2ForTAlice<'a>{
	pub cell: &'a TAlice<'a>,
}

pub struct MutexGuardForTAlice<'a>{
	mutex_ref: &'a (dyn LockableForMutex + Sync + Send),
}

#[link_section = ".rodata"]
pub static ALICE1: TAlice = TAlice {
	c_person: &EDEBFORDEB,
	id: 1,
	variable: &ALICE1VAR,
	mutex_ref: &DUMMY_MUTEX_REF,
};

pub static ALICE1VAR: SyncTAliceVar = SyncTAliceVar {
	unsafe_var: UnsafeCell::new(TAliceVar {
		count: 0,
	}),
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
pub static ALICE2: TAlice = TAlice {
	c_person: &ECAROLFORCAROL1,
	id: 2,
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
	inner: unsafe{MutexRef::from_raw_nonnull(NonZero::new(TECS_RUST_MUTEX_1).unwrap())},
};

#[link_section = ".rodata"]
pub static EALICE1FORALICE2: EAlice1ForTAlice = EAlice1ForTAlice {
	cell: &ALICE2,
};

#[link_section = ".rodata"]
pub static EALICE2FORALICE2: EAlice2ForTAlice = EAlice2ForTAlice {
	cell: &ALICE2,
};

impl TAlice<'_> {
	pub fn get_cell_ref(&'static self) -> (&dyn SHello, &i32, &mut TAliceVar, MutexGuardForTAlice) {
		self.mutex_ref.lock();
		(
			self.c_person,
			&self.id,
			unsafe{&mut *self.variable.unsafe_var.get()},
			MutexGuardForTAlice{
				mutex_ref: self.mutex_ref,
			}
		)
	}
}
