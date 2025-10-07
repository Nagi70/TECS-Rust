use crate::tecs_global::*;
pub trait SImuData {
	fn send(&'static self, imu_data: &ImuMsg);
}
