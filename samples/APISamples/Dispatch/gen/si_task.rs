use spin::Mutex;
use itron::abi::*;
use itron::unknown::unknown;
pub trait SiTask {
	fn activate(&'static self)-> ER;
	fn wakeup(&'static self)-> ER;
	fn release_wait(&'static self)-> ER;
}
