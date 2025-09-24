use crate::tecs_struct_def::*;
pub trait SVelocityStatus {
	fn send(&'static self, velocity_status: &VelocityReport);
}
