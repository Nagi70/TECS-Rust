use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{s_hello::*, t_alice::*};

pub struct TTaskbody<'a>
{
	c_person1: &'a (dyn SHello + Sync + Send),
	c_person2: &'a (dyn SHello + Sync + Send),
}

pub struct ETaskbodyForTTaskbody<'a>{
	pub cell: &'a TTaskbody<'a>,
}

#[link_section = ".rodata"]
pub static TASKBODY1: TTaskbody = TTaskbody {
	c_person1: &EALICE1FORALICE1,
	c_person2: &EALICE1FORALICE2,
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY1: ETaskbodyForTTaskbody = ETaskbodyForTTaskbody {
	cell: &TASKBODY1,
};

#[link_section = ".rodata"]
pub static TASKBODY2: TTaskbody = TTaskbody {
	c_person1: &EALICE2FORALICE1,
	c_person2: &EALICE2FORALICE2,
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY2: ETaskbodyForTTaskbody = ETaskbodyForTTaskbody {
	cell: &TASKBODY2,
};

impl TTaskbody<'_> {
	pub fn get_cell_ref(&'static self) -> (&dyn SHello, &dyn SHello) {
		(
			self.c_person1,
			self.c_person2
		)
	}
}
