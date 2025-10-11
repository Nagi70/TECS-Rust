use crate::tecs_global::*;
pub trait SControl {
	fn send(&'static self, control: &Control);
}
