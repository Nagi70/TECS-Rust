use crate::tecs_global::*;
use crate::tecs_celltype::t_utils_pose_deviation::*;
use crate::tecs_signature::s_utils_pose_deviation::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SUtilsPoseDeviation for EUtilsForTUtilsPoseDeviation{

	fn calc_lateral_deviation(&'static self, base_pose: &Pose, target_point: &nalgebra::Vector3<f64>) -> f64{

	}
	fn calc_yaw_deviation(&'static self, base_pose: &Pose, target_pose: &Pose) -> f64{

	}
}

