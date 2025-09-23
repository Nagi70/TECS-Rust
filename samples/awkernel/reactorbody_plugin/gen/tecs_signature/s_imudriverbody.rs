use crate::tecs_struct_def::*;
pub trait SImudriverbody {
	fn main(&'static self, imu: &ImuMsg, imu_raw: &mut ImuMsg);
}
