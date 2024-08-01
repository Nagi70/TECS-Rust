use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{s_hello::*, t_alice::*};

pub struct TTaskbody<'a>
{
	c_person: &'a (dyn SHello + Sync + Send),
	mutex_ref: &'a TECSDummyMutexRef,
}

unsafe impl Sync for SyncTTaskbodyVar {}

pub struct ETaskbodyForTTaskbody<'a>{
	pub cell: &'a TTaskbody<'a>,
}

pub struct MutexGuardForTTaskbody<'a>{
	mutex_ref: &'a TECSDummyMutexRef,
}

#[link_section = ".rodata"]
pub static TASKBODY1: TTaskbody = TTaskbody {
	c_person: &EALICE1FORALICE2,
	mutex_ref: &DUMMY_MUTEX_REF,
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY1: ETaskbodyForTTaskbody = ETaskbodyForTTaskbody {
	cell: &TASKBODY1,
};

#[link_section = ".rodata"]
pub static TASKBODY2: TTaskbody = TTaskbody {
	c_person: &EALICE2FORALICE2,
	mutex_ref: &DUMMY_MUTEX_REF,
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY2: ETaskbodyForTTaskbody = ETaskbodyForTTaskbody {
	cell: &TASKBODY2,
};

impl TTaskbody<'_> {
	pub fn get_cell_ref(&'static self) -> (&dyn SHello, MutexGuardForTTaskbody) {
		self.mutex_ref.lock();
		(
			self.c_person,
			MutexGuardForTTaskbody{
				mutex_ref: self.mutex_ref,
			}
		)
	}
}
