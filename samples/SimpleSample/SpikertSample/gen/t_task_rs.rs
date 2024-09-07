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
	pub taskRef: TaskRef<'a>,
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
pub static TASK: TTaskRs<ETaskbodyForTTaskbody> = TTaskRs {
	c_task_body: &ETASKBODYFORTASKBODY,
	taskRef: unsafe{TaskRef::from_raw_nonnull(NonZeroI32::new(TASK1).unwrap())},
};

#[link_section = ".rodata"]
pub static ETASKFORTASK: ETaskForTTaskRs = ETaskForTTaskRs {
	cell: &TASK,
};

#[link_section = ".rodata"]
pub static EITASKFORTASK: EiTaskForTTaskRs = EiTaskForTTaskRs {
	cell: &TASK,
};

#[link_section = ".rodata"]
pub static EIACTIVATENOTIFICATIONHANDLERFORTASK: EiActivateNotificationHandlerForTTaskRs = EiActivateNotificationHandlerForTTaskRs {
	cell: &TASK,
};

#[link_section = ".rodata"]
pub static EIWAKEUPNOTIFICATIONHANDLERFORTASK: EiWakeUpNotificationHandlerForTTaskRs = EiWakeUpNotificationHandlerForTTaskRs {
	cell: &TASK,
};

impl<T: STaskBody> TTaskRs<'_, T> {
	#[inline]
	pub fn get_cell_ref(&self) -> (&T, &TaskRef) {
		(self.c_task_body, &self.taskRef)
	}
}
