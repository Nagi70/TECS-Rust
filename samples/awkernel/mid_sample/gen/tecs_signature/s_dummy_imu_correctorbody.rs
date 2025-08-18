use crate::tecs_struct_def::*;
pub trait SDummyImuCorrectorbody {
	fn main(&'static self, imu_raw: &ImuMsg);
}
