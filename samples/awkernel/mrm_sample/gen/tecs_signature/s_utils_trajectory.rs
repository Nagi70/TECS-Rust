use crate::tecs_global::*;
pub trait SUtilsTrajectory {
	fn find_nearest_index(&'static self, points: &heapless::Vec<TrajectoryPoint, 10>, query_position: &nalgebra::Vector3<f64>)-> i32;
}
