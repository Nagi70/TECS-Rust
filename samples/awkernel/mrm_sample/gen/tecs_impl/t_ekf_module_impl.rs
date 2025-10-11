use crate::tecs_global::*;
use crate::tecs_celltype::t_ekf_module::*;
use crate::tecs_signature::{s_time_delay_kalman_filter::*, s_state_transition::*, s_measurement::*, s_mahalanobis::*, s_covariance::*, s_utils_geometry::*, s_ekf_module::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SEkfModule for EEkfModuleForTEkfModule{

	fn init(&'static self) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn accumulate_delay_time(&'static self, dt: &f64) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn find_closest_delay_time_index(&'static self, target_value: &f64) -> i32{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn predict_with_delay(&'static self, dt: &f64) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn measurement_update_twist(&'static self, twist: &TwistWithCovarianceStamped, current_time: &awkernel_lib::time::Time) -> Result<(), EkfModuleError>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn get_current_twist(&'static self, current_time: &awkernel_lib::time::Time, twist: &mut TwistWithCovarianceStamped) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn get_current_pose(&'static self, current_time: &awkernel_lib::time::Time, get_biased_yaw: &bool, pose: &mut PoseWithCovarianceStamped) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn get_current_twist_covariance(&'static self, cov: &mut nalgebra::Matrix6<f64>) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn get_current_pose_covariance(&'static self, cov: &mut nalgebra::Matrix6<f64>) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

