use spin::Mutex;
use itron::abi::*;
use itron::unknown::unknown;
pub trait SManage {
	fn manage(&'static self);
}
