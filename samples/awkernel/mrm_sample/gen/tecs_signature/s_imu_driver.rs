use crate::tecs_struct_def::*;
pub trait SImuDriver {
	fn main(&'static self, imu: &Frame, imu_raw: &mut ImuMsg);
}
