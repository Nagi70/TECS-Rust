use crate::tecs_struct_def::*;
pub trait SImuData {
	fn send(&'static self, imu_data: &ImuMsg);
}
