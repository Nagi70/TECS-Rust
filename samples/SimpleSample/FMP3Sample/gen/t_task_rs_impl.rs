use crate::{t_task_rs::*, s_task::*, si_task::*, s_task_body::*, si_notification_handler::*};

impl STask for ETaskForTTaskRs<'_>{

	#[inline]
	fn activate(&self) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn migrate_and_activate(&self, prcid: &ID) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn cancel_activate(&self) -> ER_UINT{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn migrate(&self, prcid: &ID) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn get_task_state(&self, p_tskstat: &mut STAT) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn change_priority(&self, priority: &PRI) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn change_sub_priority(&self, subPriority: &uint_t) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn get_priority(&self, p_priority: &mut PRI) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn refer(&self, pk_taskStatus: &mut T_RTSK) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn wakeup(&self) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn cancel_wakeup(&self) -> ER_UINT{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn release_wait(&self) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn suspend(&self) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn resume(&self) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn raise_terminate(&self) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn terminate(&self) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
}

impl SiTask for EiTaskForTTaskRs<'_>{

	#[inline]
	fn activate(&self) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn wakeup(&self) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
	#[inline]
	fn release_wait(&self) -> ER{
		let (c_task_body, task_ref) = self.cell.get_cell_ref();

	}
}

impl SiNotificationHandler for EiActivateNotificationHandlerForTTaskRs<'_>{

}

impl SiNotificationHandler for EiWakeUpNotificationHandlerForTTaskRs<'_>{

}

