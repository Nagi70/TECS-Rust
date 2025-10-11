use crate::tecs_global::*;
use crate::tecs_celltype::t_utils_pose_deviation::*;
use crate::tecs_signature::s_utils_pose_deviation::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SUtilsPoseDeviation for EUtilsForTUtilsPoseDeviation{

	fn calc_lateral_deviation(&'static self, base_pose: &Pose, target_point: &nalgebra::Vector3<f64>) -> f64{
		// Equivalent to autoware_utils_geometry::calc_lateral_deviation
		let base_point = &base_pose.point;
		// Yaw from quaternion: assuming z-up, planar yaw
		let q = base_pose.orientation;
		let siny_cosp = 2.0 * (q.w * q.z + q.x * q.y);
		let cosy_cosp = 1.0 - 2.0 * (q.y * q.y + q.z * q.z);
		let yaw = siny_cosp.atan2(cosy_cosp);
		let base_unit_vec = nalgebra::Vector3::new(yaw.cos(), yaw.sin(), 0.0);

		let dx = target_point.x - base_point.x;
		let dy = target_point.y - base_point.y;
		let diff_vec = nalgebra::Vector3::new(dx, dy, 0.0);

		let cross_vec = base_unit_vec.cross(&diff_vec);
		cross_vec.z
	}
	fn calc_yaw_deviation(&'static self, base_pose: &Pose, target_pose: &Pose) -> f64{
		// Equivalent to autoware_utils_geometry::calc_yaw_deviation with normalization
		let qb = base_pose.orientation;
		let qt = target_pose.orientation;
		let siny_cosp_b = 2.0 * (qb.w * qb.z + qb.x * qb.y);
		let cosy_cosp_b = 1.0 - 2.0 * (qb.y * qb.y + qb.z * qb.z);
		let base_yaw = siny_cosp_b.atan2(cosy_cosp_b);

		let siny_cosp_t = 2.0 * (qt.w * qt.z + qt.x * qt.y);
		let cosy_cosp_t = 1.0 - 2.0 * (qt.y * qt.y + qt.z * qt.z);
		let target_yaw = siny_cosp_t.atan2(cosy_cosp_t);

		let mut d = target_yaw - base_yaw;
		// normalize to [-pi, pi)
		while d > core::f64::consts::PI { d -= 2.0 * core::f64::consts::PI; }
		while d <= -core::f64::consts::PI { d += 2.0 * core::f64::consts::PI; }
		d
	}
}

