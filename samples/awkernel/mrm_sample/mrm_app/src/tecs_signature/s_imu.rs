use crate::tecs_global::*;
pub trait SImu {
	fn send(&'static self, imu: &Frame);
}
