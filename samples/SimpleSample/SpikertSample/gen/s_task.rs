use spin::Mutex;
use itron::abi::*;
use itron::task::TaskRef;
pub trait STask {
	fn activate(&self)-> ER;
	fn cancel_activate(&self)-> ER_UINT;
	fn get_task_state(&self, p_tskstat: &mut STAT)-> ER;
	fn change_priority(&self, priority: &PRI)-> ER;
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
