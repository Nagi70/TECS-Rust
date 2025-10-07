use crate::tecs_global::*;
pub trait SMahalanobis {
	fn mahalanobis2d(&'static self, x: &nalgebra::Vector2<f64>, y: &nalgebra::Matrix2x1<f64>, c: &nalgebra::Matrix2<f64>)-> f64;
}
