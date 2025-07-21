use crate::tecs_struct_def::*;
pub trait SCameraInfo {
	fn send(&'static self, camera_info: &Test);
}
