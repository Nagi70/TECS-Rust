use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{s_taskbody::*, t_taskbody::*, s_hello::*, t_alice::*, t_bob::*};

pub struct TTask<'a, T, U>
where
	T: STaskbody,
	U: SHello,
{
	c_taskbody: &'a T,
	c_person: &'a U,
	id: i32,
}

#[link_section = ".rodata"]
pub static TASK1: TTask<ETaskbodyForTTaskbody, EAlice1ForTAlice> = TTask {
	c_taskbody: &ETASKBODYFORTASKBODY1,
	c_person: &EALICE1FORALICE1,
	id: 0,
};

#[link_section = ".rodata"]
pub static TASK2: TTask<ETaskbodyForTTaskbody, EBobForTBob> = TTask {
	c_taskbody: &ETASKBODYFORTASKBODY2,
	c_person: &EBOBFORBOB,
	id: 0,
};

