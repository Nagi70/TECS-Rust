use spin::Mutex;
use itron::abi::*;
use itron::unknown::unknown;
pub trait SHello {
	fn hello_from_this(&'static self);
}
