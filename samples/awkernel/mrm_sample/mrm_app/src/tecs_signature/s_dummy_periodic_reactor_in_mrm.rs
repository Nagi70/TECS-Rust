use crate::tecs_global::*;
pub trait SDummyPeriodicReactorInMrm {
	fn main(&'static self, imu: &mut Frame, velocity_status: &mut VelocityReport);
}
