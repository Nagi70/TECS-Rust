use spin::Mutex;
use itron::abi::*;
use itron::task::TaskRef;
pub trait SiTask {
	fn activate(&self)-> ER;
	fn wakeup(&self)-> ER;
	fn releaseWait(&self)-> ER;
}
