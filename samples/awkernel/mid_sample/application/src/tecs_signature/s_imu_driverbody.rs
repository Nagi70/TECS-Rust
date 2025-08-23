use crate::tecs_struct_def::*;
pub trait SImuDriverbody {
	fn main(&'static self, imu: &Frame, imu_raw: &mut ImuMsg);
}
