use spin::Mutex;
use itron::abi::*;
use itron::task::TaskRef;
pub trait STask {
	fn activate(&self)-> ER;
	fn migrate_and_activate(&self, prcid: &ID)-> ER;
	fn cancel_activate(&self)-> ER_UINT;
	fn migrate(&self, prcid: &ID)-> ER;
	fn get_task_state(&self, p_tskstat: &mut STAT)-> ER;
	fn change_priority(&self, priority: &PRI)-> ER;
	fn change_sub_priority(&self, subPriority: &uint_t)-> ER;
	fn get_priority(&self, p_priority: &mut PRI)-> ER;
	fn refer(&self, pk_taskStatus: &mut T_RTSK)-> ER;
	fn wakeup(&self)-> ER;
	fn cancel_wakeup(&self)-> ER_UINT;
	fn release_wait(&self)-> ER;
	fn suspend(&self)-> ER;
	fn resume(&self)-> ER;
	fn raise_terminate(&self)-> ER;
	fn terminate(&self)-> ER;
}
