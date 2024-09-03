use crate::{s_motor::*, t_motor_a::*, t_motor_b::*};

pub struct TTaskbody<'a>
{
	pub c_motor: &'a (dyn SMotor + Sync + Send),
}

pub struct ETaskbodyForTTaskbody<'a>{
	pub cell: &'a TTaskbody<'a>,
}

#[link_section = ".rodata"]
pub static TASKBODY1: TTaskbody = TTaskbody {
	c_motor: &EMOTORFORMOTORA,
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY1: ETaskbodyForTTaskbody = ETaskbodyForTTaskbody {
	cell: &TASKBODY1,
};

#[link_section = ".rodata"]
pub static TASKBODY2: TTaskbody = TTaskbody {
	c_motor: &EMOTORFORMOTORB,
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY2: ETaskbodyForTTaskbody = ETaskbodyForTTaskbody {
	cell: &TASKBODY2,
};

impl<> TTaskbody<'_> {
	#[inline]
	pub fn get_cell_ref(&self) -> &dyn SMotor {
		&self.c_motor
	}
}
