use crate::tecs_global::*;
pub trait SImuCorrector {
	fn main(&'static self, imu_raw: &ImuMsg, imu_data: &mut ImuMsg);
}
