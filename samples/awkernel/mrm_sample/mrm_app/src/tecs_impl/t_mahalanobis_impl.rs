use crate::tecs_global::*;
use crate::tecs_celltype::t_mahalanobis::*;
use crate::tecs_signature::s_mahalanobis::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SMahalanobis for EMahaForTMahalanobis<'_>{

	fn mahalanobis2d(&'static self, x: &nalgebra::Vector2<f64>, y: &nalgebra::Matrix2x1<f64>, c: &nalgebra::Matrix2<f64>) -> f64{
		// Compute Mahalanobis distance: sqrt((x - y)^T * C^{-1} * (x - y))
		let d = x - y; // 2x1
		if let Some(c_inv) = c.try_inverse() {
			let v = c_inv * d; // 2x1
			let squared = d[(0, 0)] * v[(0, 0)] + d[(1, 0)] * v[(1, 0)];
			return squared.max(0.0).sqrt();
		}
		// If covariance is singular, return infinity to indicate an invalid/huge distance
		f64::INFINITY
	}
}

