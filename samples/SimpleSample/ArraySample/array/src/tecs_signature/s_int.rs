use crate::tecs_global::*;
pub trait SInt {
	fn send(&'static self, value: &i32);
}
