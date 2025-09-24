use crate::tecs_struct_def::*;
pub trait SImuDevice {
	fn read(&'static self, msg: &Frame, imu_msg: &mut ImuMsg);
}
