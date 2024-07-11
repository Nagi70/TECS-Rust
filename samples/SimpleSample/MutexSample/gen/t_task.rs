use crate::{s_taskbody::*, t_taskbody::*, s_hello::*, t_carol::*, t_bob::*};

pub struct TTask<'a, T, U>
where
	T: STaskbody,
	U: SHello,
{
	pub c_taskbody: &'a T,
	pub c_person: &'a U,
	pub id: i32,
}

#[link_section = ".rodata"]
pub static TASK1: TTask<ETaskbodyForTTaskbody, ECarolForTCarol> = TTask {
	c_taskbody: &ETASKBODYFORTASKBODY1,
	c_person: &ECAROLFORCAROL1,
	id: 0,
};

#[link_section = ".rodata"]
pub static TASK2: TTask<ETaskbodyForTTaskbody, EBobForTBob> = TTask {
	c_taskbody: &ETASKBODYFORTASKBODY2,
	c_person: &EBOBFORBOB,
	id: 0,
};

