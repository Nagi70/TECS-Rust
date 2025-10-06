use crate::tecs_struct_def::*;
pub trait SMeasurement {
	fn twist_measurement_matrix(&'static self)-> nalgebra::Matrix2x6<f64>;
	fn twist_measurement_covariance(&'static self, covairance: &nalgebra::Matrix6<f64>, smoothing_step: &u32)-> nalgebra::Matrix2<f64>;
}
