use crate::{s_sensor::*, t_sensor_a::*, t_sensor_b::*};

pub struct TTaskbody<'a>
{
	c_sensor: &'a (dyn SSensor + Sync + Send),
}

pub struct ETaskbodyForTTaskbody<'a>{
	pub cell: &'a TTaskbody<'a>,
}

#[link_section = ".rodata"]
pub static TASKBODY1: TTaskbody = TTaskbody {
	c_sensor: &ESENSORFORSENSORA,
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY1: ETaskbodyForTTaskbody = ETaskbodyForTTaskbody {
	cell: &TASKBODY1,
};

#[link_section = ".rodata"]
pub static TASKBODY2: TTaskbody = TTaskbody {
	c_sensor: &ESENSORFORSENSORB,
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY2: ETaskbodyForTTaskbody = ETaskbodyForTTaskbody {
	cell: &TASKBODY2,
};

impl<> TTaskbody<'_> {
	pub fn get_cell_ref(&'static self) -> &'static dyn SSensor {
		self.c_sensor
	}
}
