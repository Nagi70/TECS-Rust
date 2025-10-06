use crate::tecs_struct_def::*;
pub trait SUtilsGeometry {
	fn get_rpy(&'static self, quat: &nalgebra::Quaternion<f64>)-> nalgebra::Vector3<f64>;
	fn create_quaternion_from_rpy(&'static self, roll: &f64, pitch: &f64, yaw: &f64)-> nalgebra::Quaternion<f64>;
}
