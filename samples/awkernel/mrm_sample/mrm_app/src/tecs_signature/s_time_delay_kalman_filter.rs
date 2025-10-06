use crate::tecs_struct_def::*;
pub trait STimeDelayKalmanFilter {
	fn init(&'static self, x: &nalgebra::Vector6<f64>, p: &nalgebra::Matrix6<f64>, max_delay_step: &i32);
	fn predict_with_delay(&'static self, x_next: &nalgebra::Vector6<f64>, a: &nalgebra::Matrix6<f64>, q: &nalgebra::Matrix6<f64>);
	fn update_with_delay(&'static self, y: &nalgebra::Vector2<f64>, c: &nalgebra::Matrix2x6<f64>, r: &nalgebra::Matrix2<f64>, delay_step: &i32)-> Result<(), KalmanFilterError>;
	fn get_latest_x(&'static self)-> nalgebra::Matrix6x1<f64>;
	fn get_latest_p(&'static self)-> nalgebra::Matrix6<f64>;
	fn get_xelement(&'static self, i: &u32)-> f64;
}
