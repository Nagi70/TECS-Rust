use spin::Mutex;
use itron::abi::*;
use itron::unknown::unknown;
pub trait STaskbody {
	fn main(&self);
}
