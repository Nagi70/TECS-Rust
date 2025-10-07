use crate::tecs_global::*;
pub trait SVehicleVelocityConverter {
	fn main(&'static self, velocity_status: &VelocityReport, twist_with_covariance: &mut TwistWithCovarianceStamped);
}
