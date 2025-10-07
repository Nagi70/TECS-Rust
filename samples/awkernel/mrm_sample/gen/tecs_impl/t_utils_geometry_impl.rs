use crate::tecs_global::*;
use crate::tecs_celltype::t_utils_geometry::*;
use crate::tecs_signature::s_utils_geometry::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SUtilsGeometry for EUtilsForTUtilsGeometry<'_>{

	fn get_rpy(&'static self, quat: &nalgebra::Quaternion<f64>) -> nalgebra::Vector3<f64>{

	}
	fn create_quaternion_from_rpy(&'static self, roll: &f64, pitch: &f64, yaw: &f64) -> nalgebra::Quaternion<f64>{

	}
}

