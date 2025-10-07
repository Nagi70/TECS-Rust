use crate::tecs_global::*;
pub trait SImuRaw {
	fn send(&'static self, imu_raw: &ImuMsg);
}
