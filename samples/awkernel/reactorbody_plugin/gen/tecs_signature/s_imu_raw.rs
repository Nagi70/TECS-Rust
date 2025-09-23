use crate::tecs_struct_def::*;
pub trait SImuRaw {
	fn send(&'static self, imu_raw: &ImuMsg);
}
