use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_mahalanobis::*;
use crate::tecs_signature::s_mahalanobis::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SMahalanobis for EMahaForTMahalanobis<'_>{

	fn mahalanobis2d(&'static self, x: &nalgebra::Vector2<f64>, y: &nalgebra::Matrix2x1<f64>, c: &nalgebra::Matrix2<f64>) -> f64{

	}
}

