use crate::tecs_global::*;
pub trait SImuDriver {
	fn main(&'static self, imu: &Frame, imu_raw: &mut ImuMsg);
}
