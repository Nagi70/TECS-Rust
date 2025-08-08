use crate::tecs_struct_def::*;
pub trait SRateMonitor {
	fn tick(&'static self);
}
