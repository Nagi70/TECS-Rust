pub trait STask {
	fn activate(&'static self)-> ER;
	fn migrate_and_activate(&'static self, prcid: &ID)-> ER;
	fn cancel_activate(&'static self)-> ER_UINT;
	fn migrate(&'static self, prcid: &ID)-> ER;
	fn get_task_state(&'static self, p_tskstat: &mut STAT)-> ER;
	fn change_priority(&'static self, priority: &PRI)-> ER;
	fn change_sub_priority(&'static self, subPriority: &uint_t)-> ER;
	fn get_priority(&'static self, p_priority: &mut PRI)-> ER;
	fn refer(&'static self, pk_taskStatus: &mut T_RTSK)-> ER;
	fn wakeup(&'static self)-> ER;
	fn cancel_wakeup(&'static self)-> ER_UINT;
	fn release_wait(&'static self)-> ER;
	fn suspend(&'static self)-> ER;
	fn resume(&'static self)-> ER;
	fn raise_terminate(&'static self)-> ER;
	fn terminate(&'static self)-> ER;
}
