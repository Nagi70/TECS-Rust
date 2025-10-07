use crate::tecs_global::*;
pub trait SVelocityStatus {
	fn send(&'static self, velocity_status: &VelocityReport);
}
