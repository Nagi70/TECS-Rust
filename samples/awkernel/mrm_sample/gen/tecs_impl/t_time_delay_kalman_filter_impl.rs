use crate::tecs_global::*;
use crate::tecs_celltype::t_time_delay_kalman_filter::*;
use crate::tecs_signature::s_time_delay_kalman_filter::*;
use awkernel_lib::sync::mutex::MCSNode;
impl STimeDelayKalmanFilter for EKalmanForTTimeDelayKalmanFilter{

	fn init(&'static self, x: &nalgebra::Matrix6x1<f64>, p: &nalgebra::Matrix6<f64>) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn predict_with_delay(&'static self, x_next: &nalgebra::Matrix6x1<f64>, a: &nalgebra::Matrix6<f64>, q: &nalgebra::Matrix6<f64>) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn update_with_delay(&'static self, y: &nalgebra::Matrix2x1<f64>, c: &nalgebra::Matrix2x6<f64>, r: &nalgebra::Matrix2<f64>, delay_step: &i32) -> Result<(), KalmanFilterError>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn get_latest_x(&'static self) -> nalgebra::Matrix6x1<f64>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn get_latest_p(&'static self) -> nalgebra::Matrix6<f64>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn get_xelement(&'static self, i: &u32) -> f64{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

