use crate::tecs_global::*;
use crate::tecs_celltype::t_utils_trajectory::*;
use crate::tecs_signature::s_utils_trajectory::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SUtilsTrajectory for EUtilsForTUtilsTrajectory{


	fn find_nearest_index(&'static self, points: &heapless::Vec<TrajectoryPoint, 10>, query_position: &nalgebra::Vector3<f64>) -> i32 {
		if points.is_empty() {
			return 0;
		}
		let mut best_idx: usize = 0;
		let mut best_dist2 = core::f64::MAX;
		for (i, p) in points.iter().enumerate() {
			let dx = p.pose.point.x - query_position.x;
			let dy = p.pose.point.y - query_position.y;
			let d2 = dx * dx + dy * dy;
			if d2 < best_dist2 {
				best_dist2 = d2;
				best_idx = i;
			}
		}
		best_idx as i32
	}
}

