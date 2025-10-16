use crate::tecs_global::*;
pub trait SInt {
	fn send(&self, value: &i32);
}
