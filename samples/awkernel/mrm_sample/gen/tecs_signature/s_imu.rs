use crate::tecs_struct_def::*;
pub trait SImu {
	fn send(&'static self, imu: &Frame);
}
