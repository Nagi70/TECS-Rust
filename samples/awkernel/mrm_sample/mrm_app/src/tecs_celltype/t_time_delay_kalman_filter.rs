use crate::tecs_variable::*;
pub struct TTimeDelayKalmanFilter<'a>{
	dim_x: i32,
	max_delay_step: i32,
	dim_x_ex: i32,
	d_dim_x: i32,
	dim_y_twist: i32,
	variable: &'a TECSVariable<TTimeDelayKalmanFilterVar>,
}

pub struct TTimeDelayKalmanFilterVar{
	pub x: nalgebra::SMatrix<f64, 300, 1>,
	pub p: nalgebra::SMatrix<f64, 300, 300>,
}

pub struct EKalmanForTTimeDelayKalmanFilter<'a>{
	pub cell: &'a TTimeDelayKalmanFilter<'a>,
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
		x: Default::default(),
		p: Default::default(),
	}
));
pub static EKALMANFORTIMEDELAYKALMANFILTER: EKalmanForTTimeDelayKalmanFilter = EKalmanForTTimeDelayKalmanFilter {
	cell: &TIMEDELAYKALMANFILTER,
};

impl<'a> TTimeDelayKalmanFilter<'a> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut awkernel_lib::sync::mutex::MCSNode<TTimeDelayKalmanFilterVar>) -> LockGuardForTTimeDelayKalmanFilter<'_>
	where
		'b: 'a,
	{
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
