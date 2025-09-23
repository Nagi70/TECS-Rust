use crate::tecs_struct_def::*;
pub trait SDummyImubody {
	fn main(&'static self, imu: &mut ImuMsg);
}
