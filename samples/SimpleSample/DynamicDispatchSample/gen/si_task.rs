use spin::Mutex;
use itron::abi::*;
use itron::unknown::unknown;
pub trait SiTask {
	fn activate(&self)-> ER;
	fn wakeup(&self)-> ER;
	fn release_wait(&self)-> ER;
}
