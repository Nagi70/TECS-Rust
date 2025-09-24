use crate::tecs_struct_def::*;
pub trait SDummyPeriodicReactorInMrm {
	fn main(&'static self, imu: &mut Frame, velocity_status: &mut VelocityReport);
}
