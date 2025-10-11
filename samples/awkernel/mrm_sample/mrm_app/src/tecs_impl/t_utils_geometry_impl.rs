use crate::tecs_global::*;
use crate::tecs_celltype::t_utils_geometry::*;
use crate::tecs_signature::s_utils_geometry::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SUtilsGeometry for EUtilsForTUtilsGeometry{

	fn get_rpy(&'static self, quat: &nalgebra::Quaternion<f64>) -> nalgebra::Vector3<f64>{
		// Exactly mirror tf2::Matrix3x3(q).getEulerYPR (ZYX / fixed-axes RPY) including gimbal lock handling
		let (mut w, mut x, mut y, mut z) = (quat.w, quat.i, quat.j, quat.k);
		// Normalize quaternion to unit length
		let norm = (w * w + x * x + y * y + z * z).sqrt();
		if norm > 0.0 { w /= norm; x /= norm; y /= norm; z /= norm; }

		// Build rotation matrix elements from quaternion (matching tf2::Matrix3x3::setRotation)
		let r11 = 1.0 - 2.0 * (y * y + z * z);
		let r12 = 2.0 * (x * y - z * w);
		let r13 = 2.0 * (x * z + y * w);
		let r21 = 2.0 * (x * y + z * w);
		let _r22 = 1.0 - 2.0 * (x * x + z * z); // not used directly below
		let _r23 = 2.0 * (y * z - x * w);      // not used directly below
		let r31 = 2.0 * (x * z - y * w);
		let r32 = 2.0 * (y * z + x * w);
		let r33 = 1.0 - 2.0 * (x * x + y * y);

		// Follow tf2::Matrix3x3::getEulerYPR logic
		// Check singularity: |r31| >= 1 -> gimbal lock
		if r31.abs() >= 1.0 {
			let yaw = 0.0; // tf2 chooses yaw=0 in gimbal lock
			let delta = r32.atan2(r33);
			let (pitch, roll) = if r31 < 0.0 {
				(std::f64::consts::FRAC_PI_2, delta) // locked down: +pi/2
			} else {
				(-std::f64::consts::FRAC_PI_2, delta) // locked up: -pi/2
			};
			return nalgebra::Vector3::new(roll, pitch, yaw);
		}

		// Regular case
		let pitch = -(r31.asin());
		let c = pitch.cos();
		let roll = (r32 / c).atan2(r33 / c);
		let yaw = (r21 / c).atan2(r11 / c);
		nalgebra::Vector3::new(roll, pitch, yaw)
	}
	fn create_quaternion_from_rpy(&'static self, roll: &f64, pitch: &f64, yaw: &f64) -> nalgebra::Quaternion<f64>{
		// Create quaternion from roll-pitch-yaw (ZYX), matching tf2::Quaternion::setRPY
		let (hr, hp, hy) = (0.5 * *roll, 0.5 * *pitch, 0.5 * *yaw);
		let (cr, sr) = (hr.cos(), hr.sin());
		let (cp, sp) = (hp.cos(), hp.sin());
		let (cy, sy) = (hy.cos(), hy.sin());
		let w = cr * cp * cy + sr * sp * sy;
		let x = sr * cp * cy - cr * sp * sy;
		let y = cr * sp * cy + sr * cp * sy;
		let z = cr * cp * sy - sr * sp * cy;

		// nalgebra::Quaternion::new(w, x, y, z) => Vector4::new(x, y, z, w)
		nalgebra::Quaternion::new(w, x, y, z)
	}
}

