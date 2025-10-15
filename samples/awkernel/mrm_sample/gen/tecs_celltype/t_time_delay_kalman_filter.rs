use crate::tecs_variable::*;
pub struct TTimeDelayKalmanFilter{
	dim_x: i32,
	max_delay_step: i32,
	dim_x_ex: i32,
	d_dim_x: i32,
	dim_y_twist: i32,
	variable: &'static TECSVariable<TTimeDelayKalmanFilterVar>,
}

pub struct TTimeDelayKalmanFilterVar {
	pub x: nalgebra::SMatrix<f64, 300, 1>,
	pub p: nalgebra::SMatrix<f64, 300, 300>,
}

pub struct EKalmanForTTimeDelayKalmanFilter {
	pub cell: &'static TTimeDelayKalmanFilter,
}

pub struct LockGuardForTTimeDelayKalmanFilter<'a>{
	pub dim_x: &'a i32,
	pub max_delay_step: &'a i32,
	pub dim_x_ex: &'a i32,
	pub d_dim_x: &'a i32,
	pub dim_y_twist: &'a i32,
	pub var: TECSVarGuard<'a, TTimeDelayKalmanFilterVar>,
}

static TIMEDELAYKALMANFILTER: TTimeDelayKalmanFilter = TTimeDelayKalmanFilter {
	dim_x: 6,
	max_delay_step: 50,
	dim_x_ex: 300,
	d_dim_x: 294,
	dim_y_twist: 2,
	variable: &TIMEDELAYKALMANFILTERVAR,
};

static TIMEDELAYKALMANFILTERVAR: TECSVariable<TTimeDelayKalmanFilterVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TTimeDelayKalmanFilterVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
	x: nalgebra::SMatrix::from_row_slice(&[0.0; 300]),
	p: nalgebra::SMatrix::from_row_slice(&[0.0; 90000]),
	}
));
pub static EKALMANFORTIMEDELAYKALMANFILTER: EKalmanForTTimeDelayKalmanFilter = EKalmanForTTimeDelayKalmanFilter {
	cell: &TIMEDELAYKALMANFILTER,
};

impl TTimeDelayKalmanFilter {
	#[inline]
	pub fn get_cell_ref<'node>(&'static self, node: &'node mut awkernel_lib::sync::mutex::MCSNode<TTimeDelayKalmanFilterVar>) -> LockGuardForTTimeDelayKalmanFilter<'node> {
		LockGuardForTTimeDelayKalmanFilter {
			dim_x: &self.dim_x,
			max_delay_step: &self.max_delay_step,
			dim_x_ex: &self.dim_x_ex,
			d_dim_x: &self.d_dim_x,
			dim_y_twist: &self.dim_y_twist,
			var: self.variable.lock(node),
		}
	}
}
