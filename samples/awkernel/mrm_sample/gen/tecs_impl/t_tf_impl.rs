use crate::tecs_global::*;
use crate::tecs_celltype::t_tf::*;
use crate::tecs_signature::s_tf::*;
use awkernel_lib::sync::mutex::MCSNode;
impl STf for ETfForTTf{

	fn transform_covariance(&'static self, cov: &nalgebra::Matrix3<f64>) -> nalgebra::Matrix3<f64>{

	}
	fn transform_vector3(&'static self, vec: &mut nalgebra::Vector3<f64>) -> nalgebra::Vector3<f64>{

	}
}

