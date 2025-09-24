use crate::tecs_struct_def::*;
pub trait SImuCorrector {
	fn main(&'static self, imu_raw: &ImuMsg, imu_data: &mut ImuMsg);
}
