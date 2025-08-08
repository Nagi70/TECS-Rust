use crate::tecs_struct_def::*;
pub trait SImuDevice {
	fn open(&'static self);
	fn read(&'static self, p_data: &mut ImuData);
	fn close(&'static self);
}
