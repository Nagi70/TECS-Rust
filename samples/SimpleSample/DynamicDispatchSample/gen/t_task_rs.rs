use crate::kernel_cfg::*;
use itron::abi::*;
use itron::task::TaskRef;
use core::num::NonZeroI32;
use crate::{s_task_body::*, t_taskbody::*};

pub struct TTaskRs<'a, T>
where
	T: STaskBody,
{
	pub c_task_body: &'a T,
	pub task_ref: TaskRef<'a>,
}

pub struct ETaskForTTaskRs<'a>{
	pub cell: &'a TTaskRs<'a, ETaskbodyForTTaskbody<'a>>,
}

pub struct EiTaskForTTaskRs<'a>{
	pub cell: &'a TTaskRs<'a, ETaskbodyForTTaskbody<'a>>,
}

pub struct EiActivateNotificationHandlerForTTaskRs<'a>{
	pub cell: &'a TTaskRs<'a, ETaskbodyForTTaskbody<'a>>,
}

pub struct EiWakeUpNotificationHandlerForTTaskRs<'a>{
	pub cell: &'a TTaskRs<'a, ETaskbodyForTTaskbody<'a>>,
}

#[link_section = ".rodata"]
pub static TASK1: TTaskRs<ETaskbodyForTTaskbody> = TTaskRs {
	c_task_body: &ETASKBODYFORTASKBODY1,
	task_ref: unsafe{TaskRef::from_raw_nonnull(NonZeroI32::new(TASK1).unwrap())},
};

#[link_section = ".rodata"]
pub static ETASKFORTASK1: ETaskForTTaskRs = ETaskForTTaskRs {
	cell: &TASK1,
};

#[link_section = ".rodata"]
pub static EITASKFORTASK1: EiTaskForTTaskRs = EiTaskForTTaskRs {
	cell: &TASK1,
};

#[link_section = ".rodata"]
pub static EIACTIVATENOTIFICATIONHANDLERFORTASK1: EiActivateNotificationHandlerForTTaskRs = EiActivateNotificationHandlerForTTaskRs {
	cell: &TASK1,
};

#[link_section = ".rodata"]
pub static EIWAKEUPNOTIFICATIONHANDLERFORTASK1: EiWakeUpNotificationHandlerForTTaskRs = EiWakeUpNotificationHandlerForTTaskRs {
	cell: &TASK1,
};

#[link_section = ".rodata"]
pub static TASK2: TTaskRs<ETaskbodyForTTaskbody> = TTaskRs {
	c_task_body: &ETASKBODYFORTASKBODY2,
	task_ref: unsafe{TaskRef::from_raw_nonnull(NonZeroI32::new(TASK2).unwrap())},
};

#[link_section = ".rodata"]
pub static ETASKFORTASK2: ETaskForTTaskRs = ETaskForTTaskRs {
	cell: &TASK2,
};

#[link_section = ".rodata"]
pub static EITASKFORTASK2: EiTaskForTTaskRs = EiTaskForTTaskRs {
	cell: &TASK2,
};

#[link_section = ".rodata"]
pub static EIACTIVATENOTIFICATIONHANDLERFORTASK2: EiActivateNotificationHandlerForTTaskRs = EiActivateNotificationHandlerForTTaskRs {
	cell: &TASK2,
};

#[link_section = ".rodata"]
pub static EIWAKEUPNOTIFICATIONHANDLERFORTASK2: EiWakeUpNotificationHandlerForTTaskRs = EiWakeUpNotificationHandlerForTTaskRs {
	cell: &TASK2,
};

impl<T: STaskBody> TTaskRs<'_, T> {
	#[inline]
	pub fn get_cell_ref(&self) -> (&T, &TaskRef) {
		(&self.c_task_body, &self.task_ref)
	}
}
