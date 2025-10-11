use crate::tecs_global::*;
use crate::tecs_celltype::t_utils_trajectory::*;
use crate::tecs_signature::s_utils_trajectory::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SUtilsTrajectory for EUtilsForTUtilsTrajectory{

	fn find_nearest_index(&'static self, points: &heapless::Vec<TrajectoryPoint, 10>, query_position: &nalgebra::Vector3<f64>) -> i32{

	}
}

