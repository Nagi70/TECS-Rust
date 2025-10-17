use crate::tecs_global::*;
use crate::tecs_celltype::t_utils_pose_deviation::*;
use crate::tecs_signature::s_utils_pose_deviation::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SUtilsPoseDeviation for EUtilsForTUtilsPoseDeviation{

	fn calc_lateral_deviation(&self, base_pose: &Pose, target_point: &nalgebra::Vector3<f64>) -> f64 {
		// Equivalent to autoware_utils_geometry::calc_lateral_deviation
		let base_point = &base_pose.point;
		// Yaw from quaternion: assuming z-up, planar yaw
		let q = base_pose.orientation;
		let siny_cosp = 2.0 * (q.w * q.k + q.i * q.j);
		let cosy_cosp = 1.0 - 2.0 * (q.j * q.j + q.k * q.k);
		let yaw = libm::atan2(siny_cosp, cosy_cosp);
		let base_unit_vec = nalgebra::Vector3::new(libm::cos(yaw), libm::sin(yaw), 0.0);
		
		let dx = target_point.x - base_point.x;
		let dy = target_point.y - base_point.y;
		let diff_vec = nalgebra::Vector3::new(dx, dy, 0.0);

		let cross_vec = base_unit_vec.cross(&diff_vec);
		cross_vec.z
	}
	fn calc_yaw_deviation(&self, base_pose: &Pose, target_pose: &Pose) -> f64 {
		// Equivalent to autoware_utils_geometry::calc_yaw_deviation with normalization
		let qb = base_pose.orientation;
		let qt = target_pose.orientation;
		let siny_cosp_b = 2.0 * (qb.w * qb.k + qb.i * qb.j);
		let cosy_cosp_b = 1.0 - 2.0 * (qb.j * qb.j + qb.k * qb.k);
		let base_yaw = libm::atan2(siny_cosp_b, cosy_cosp_b);

		let siny_cosp_t = 2.0 * (qt.w * qt.k + qt.i * qt.j);
		let cosy_cosp_t = 1.0 - 2.0 * (qt.j * qt.j + qt.k * qt.k);
		let target_yaw = libm::atan2(siny_cosp_t, cosy_cosp_t);

		let mut d = target_yaw - base_yaw;
		// normalize to [-pi, pi)
		while d > core::f64::consts::PI { d -= 2.0 * core::f64::consts::PI; }
		while d <= -core::f64::consts::PI { d += 2.0 * core::f64::consts::PI; }
		d
	}
}

