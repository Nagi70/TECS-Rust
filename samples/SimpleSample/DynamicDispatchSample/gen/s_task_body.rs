use spin::Mutex;
pub trait STaskBody {
	fn main(&self);
}
