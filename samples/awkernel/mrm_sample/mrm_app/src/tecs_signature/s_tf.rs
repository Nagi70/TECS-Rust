use crate::tecs_global::*;
pub trait STf {
	fn transform_covariance(&'static self, cov: &nalgebra::Matrix3<f64>)-> nalgebra::Matrix3<f64>;
	fn transform_vector3(&'static self, vec: &mut nalgebra::Vector3<f64>)-> nalgebra::Vector3<f64>;
}
