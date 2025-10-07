use crate::tecs_global::*;
pub trait SImuDevice {
	fn read(&'static self, msg: &Frame, imu_msg: &mut ImuMsg);
}
