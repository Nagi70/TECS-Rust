use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{s_taskbody::*, t_taskbody::*};

pub struct TTask<'a, T>
where
	T: STaskbody,
{
	c_taskbody: &'a T,
	id: i32,
}

#[link_section = ".rodata"]
pub static TASK1: TTask<ETaskbodyForTTaskbody> = TTask {
	c_taskbody: &ETASKBODYFORTASKBODY1,
	id: 1,
};

#[link_section = ".rodata"]
pub static TASK2: TTask<ETaskbodyForTTaskbody> = TTask {
	c_taskbody: &ETASKBODYFORTASKBODY2,
	id: 2,
};

#[link_section = ".rodata"]
pub static TASK3: TTask<ETaskbodyForTTaskbody> = TTask {
	c_taskbody: &ETASKBODYFORTASKBODY3,
	id: 3,
};

#[link_section = ".rodata"]
pub static TASK4: TTask<ETaskbodyForTTaskbody> = TTask {
	c_taskbody: &ETASKBODYFORTASKBODY4,
	id: 4,
};

