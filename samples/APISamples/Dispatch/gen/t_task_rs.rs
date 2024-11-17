use itron::task::TaskRef;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{s_task_body::*, t_mmbody::*, t_motorbody::*, t_ssbody::*, t_sensorbody::*};

pub struct TTaskRs<'a>
{
	pub c_task_body: &'a (dyn STaskBody + Sync + Send),
	task_ref: TaskRef<'a>,
}

pub struct ETaskForTTaskRs<'a>{
	pub cell: &'a TTaskRs<'a>,
}

pub struct EiTaskForTTaskRs<'a>{
	pub cell: &'a TTaskRs<'a>,
}

pub struct EiActivateNotificationHandlerForTTaskRs<'a>{
	pub cell: &'a TTaskRs<'a>,
}

pub struct EiWakeUpNotificationHandlerForTTaskRs<'a>{
	pub cell: &'a TTaskRs<'a>,
}

#[link_section = ".rodata"]
pub static TASK1: TTaskRs = TTaskRs {
	c_task_body: &EMMBODYFORMMBODY,
	task_ref: unsafe{TaskRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_TASK1).unwrap())},
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
pub static TASK2: TTaskRs = TTaskRs {
	c_task_body: &EMOTORBODYFORMOTORBODY,
	task_ref: unsafe{TaskRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_TASK2).unwrap())},
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

#[link_section = ".rodata"]
pub static TASK3: TTaskRs = TTaskRs {
	c_task_body: &ESSBODYFORSSBODY,
	task_ref: unsafe{TaskRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_TASK3).unwrap())},
};

#[link_section = ".rodata"]
pub static ETASKFORTASK3: ETaskForTTaskRs = ETaskForTTaskRs {
	cell: &TASK3,
};

#[link_section = ".rodata"]
pub static EITASKFORTASK3: EiTaskForTTaskRs = EiTaskForTTaskRs {
	cell: &TASK3,
};

#[link_section = ".rodata"]
pub static EIACTIVATENOTIFICATIONHANDLERFORTASK3: EiActivateNotificationHandlerForTTaskRs = EiActivateNotificationHandlerForTTaskRs {
	cell: &TASK3,
};

#[link_section = ".rodata"]
pub static EIWAKEUPNOTIFICATIONHANDLERFORTASK3: EiWakeUpNotificationHandlerForTTaskRs = EiWakeUpNotificationHandlerForTTaskRs {
	cell: &TASK3,
};

#[link_section = ".rodata"]
pub static TASK4: TTaskRs = TTaskRs {
	c_task_body: &ESENSORBODYFORSENSORBODY,
	task_ref: unsafe{TaskRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_TASK4).unwrap())},
};

#[link_section = ".rodata"]
pub static ETASKFORTASK4: ETaskForTTaskRs = ETaskForTTaskRs {
	cell: &TASK4,
};

#[link_section = ".rodata"]
pub static EITASKFORTASK4: EiTaskForTTaskRs = EiTaskForTTaskRs {
	cell: &TASK4,
};

#[link_section = ".rodata"]
pub static EIACTIVATENOTIFICATIONHANDLERFORTASK4: EiActivateNotificationHandlerForTTaskRs = EiActivateNotificationHandlerForTTaskRs {
	cell: &TASK4,
};

#[link_section = ".rodata"]
pub static EIWAKEUPNOTIFICATIONHANDLERFORTASK4: EiWakeUpNotificationHandlerForTTaskRs = EiWakeUpNotificationHandlerForTTaskRs {
	cell: &TASK4,
};

impl<> TTaskRs<'_> {
	#[inline]
	pub fn get_cell_ref(&'static self) -> (&'static dyn STaskBody, &'static TaskRef) {
		(
			self.c_task_body,
			&self.task_ref
		)
	}
}
