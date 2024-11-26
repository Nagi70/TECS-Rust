use crate::{s_hello::*, t_alice::*, t_bob::*};

pub struct TTaskbody<'a>
{
	c_person: &'a (dyn SHello + Sync + Send),
}

pub struct ETaskbodyForTTaskbody<'a>{
	pub cell: &'a TTaskbody<'a>,
}

#[link_section = ".rodata"]
pub static TASKBODY1: TTaskbody = TTaskbody {
	c_person: &EALICE1FORALICE,
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY1: ETaskbodyForTTaskbody = ETaskbodyForTTaskbody {
	cell: &TASKBODY1,
};

#[link_section = ".rodata"]
pub static TASKBODY2: TTaskbody = TTaskbody {
	c_person: &EALICE2FORALICE,
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY2: ETaskbodyForTTaskbody = ETaskbodyForTTaskbody {
	cell: &TASKBODY2,
};

#[link_section = ".rodata"]
pub static TASKBODY3: TTaskbody = TTaskbody {
	c_person: &EBOB2FORBOB2,
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY3: ETaskbodyForTTaskbody = ETaskbodyForTTaskbody {
	cell: &TASKBODY3,
};

impl<> TTaskbody<'_> {
	pub fn get_cell_ref(&'static self) -> &'static dyn SHello {
		self.c_person
	}
}
