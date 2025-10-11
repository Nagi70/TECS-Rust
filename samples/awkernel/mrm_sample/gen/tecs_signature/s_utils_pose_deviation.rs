use crate::tecs_global::*;
pub trait SUtilsPoseDeviation {
	fn calc_lateral_deviation(&'static self, base_pose: &Pose, target_point: &nalgebra::Vector3<f64>)-> f64;
	fn calc_yaw_deviation(&'static self, base_pose: &Pose, target_pose: &Pose)-> f64;
}
