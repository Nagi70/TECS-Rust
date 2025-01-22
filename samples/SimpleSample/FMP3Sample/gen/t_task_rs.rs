use itron::task::TaskRef;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{s_task_body::*, t_print::*};

pub struct TTaskRs<'a, T>
where
	T: STaskBody,
{
	pub c_task_body: &'a T,
	task_ref: TaskRef<'a>,
}

pub struct ETaskForTTaskRs<'a>{
	pub cell: &'a TTaskRs<'a, EPrintForTPrint<'a>>,
}

pub struct EiTaskForTTaskRs<'a>{
	pub cell: &'a TTaskRs<'a, EPrintForTPrint<'a>>,
}

pub struct EiActivateNotificationHandlerForTTaskRs<'a>{
	pub cell: &'a TTaskRs<'a, EPrintForTPrint<'a>>,
}

pub struct EiWakeUpNotificationHandlerForTTaskRs<'a>{
	pub cell: &'a TTaskRs<'a, EPrintForTPrint<'a>>,
}

#[link_section = ".rodata"]
pub static RPROCESSOR1SYMMETRIC_TASK1_1: TTaskRs<EPrintForTPrint> = TTaskRs {
	c_task_body: &EPRINTFORRPROCESSOR1SYMMETRIC_PRINT1_1,
	task_ref: unsafe{TaskRef::from_raw_nonnull(NonZeroI32::new(TSKID_1_1).unwrap())},
};

#[link_section = ".rodata"]
pub static ETASKFORRPROCESSOR1SYMMETRIC_TASK1_1: ETaskForTTaskRs = ETaskForTTaskRs {
	cell: &RPROCESSOR1SYMMETRIC_TASK1_1,
};

#[link_section = ".rodata"]
pub static EITASKFORRPROCESSOR1SYMMETRIC_TASK1_1: EiTaskForTTaskRs = EiTaskForTTaskRs {
	cell: &RPROCESSOR1SYMMETRIC_TASK1_1,
};

#[link_section = ".rodata"]
pub static EIACTIVATENOTIFICATIONHANDLERFORRPROCESSOR1SYMMETRIC_TASK1_1: EiActivateNotificationHandlerForTTaskRs = EiActivateNotificationHandlerForTTaskRs {
	cell: &RPROCESSOR1SYMMETRIC_TASK1_1,
};

#[link_section = ".rodata"]
pub static EIWAKEUPNOTIFICATIONHANDLERFORRPROCESSOR1SYMMETRIC_TASK1_1: EiWakeUpNotificationHandlerForTTaskRs = EiWakeUpNotificationHandlerForTTaskRs {
	cell: &RPROCESSOR1SYMMETRIC_TASK1_1,
};

#[link_section = ".rodata"]
pub static RPROCESSOR2SYMMETRIC_TASK2_1: TTaskRs<EPrintForTPrint> = TTaskRs {
	c_task_body: &EPRINTFORRPROCESSOR2SYMMETRIC_PRINT2_1,
	task_ref: unsafe{TaskRef::from_raw_nonnull(NonZeroI32::new(TSKID_2_1).unwrap())},
};

#[link_section = ".rodata"]
pub static ETASKFORRPROCESSOR2SYMMETRIC_TASK2_1: ETaskForTTaskRs = ETaskForTTaskRs {
	cell: &RPROCESSOR2SYMMETRIC_TASK2_1,
};

#[link_section = ".rodata"]
pub static EITASKFORRPROCESSOR2SYMMETRIC_TASK2_1: EiTaskForTTaskRs = EiTaskForTTaskRs {
	cell: &RPROCESSOR2SYMMETRIC_TASK2_1,
};

#[link_section = ".rodata"]
pub static EIACTIVATENOTIFICATIONHANDLERFORRPROCESSOR2SYMMETRIC_TASK2_1: EiActivateNotificationHandlerForTTaskRs = EiActivateNotificationHandlerForTTaskRs {
	cell: &RPROCESSOR2SYMMETRIC_TASK2_1,
};

#[link_section = ".rodata"]
pub static EIWAKEUPNOTIFICATIONHANDLERFORRPROCESSOR2SYMMETRIC_TASK2_1: EiWakeUpNotificationHandlerForTTaskRs = EiWakeUpNotificationHandlerForTTaskRs {
	cell: &RPROCESSOR2SYMMETRIC_TASK2_1,
};

impl<T: STaskBody> TTaskRs<'_, T> {
	#[inline]
	pub fn get_cell_ref(&'static self) -> (&'static T, &'static TaskRef) {
		(
			self.c_task_body,
			&self.task_ref
		)
	}
}
