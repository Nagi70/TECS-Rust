use spin::Mutex;
use itron::abi::*;
use itron::task::TaskRef;
pub trait STask {
	fn activate(&self)-> ER;
	fn cancelActivate(&self)-> ER_UINT;
	fn getTaskState(&self, p_tskstat: &mut STAT)-> ER;
	fn changePriority(&self, priority: &PRI)-> ER;
	fn getPriority(&self, p_priority: &mut PRI)-> ER;
	fn refer(&self, pk_taskStatus: &mut T_RTSK)-> ER;
	fn wakeup(&self)-> ER;
	fn cancelWakeup(&self)-> ER_UINT;
	fn releaseWait(&self)-> ER;
	fn suspend(&self)-> ER;
	fn resume(&self)-> ER;
	fn raiseTerminate(&self)-> ER;
	fn terminate(&self)-> ER;
}
