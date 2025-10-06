use crate::tecs_variable::*;
use crate::tecs_signature::{s_time_delay_kalman_filter::*, s_state_transition::*, s_measurement::*, s_mahalanobis::*, s_covariance::*, s_utils_geometry::*};

use crate::tecs_celltype::{t_time_delay_kalman_filter::*, t_state_transition::*, t_measurement::*, t_mahalanobis::*, t_covariance::*, t_utils_geometry::*};

pub struct TEkfModule<'a, T, U, V, W, X, Y>
where
	T: STimeDelayKalmanFilter,
	U: SStateTransition,
	V: SMeasurement,
	W: SMahalanobis,
	X: SCovariance,
	Y: SUtilsGeometry,
{
	c_kalman: &'a T,
	c_state: &'a U,
	c_measure: &'a V,
	c_maha: &'a W,
	c_cov: &'a X,
	c_utils: &'a Y,
	extend_state_step: i32,
	enable_yaw_bias_estimation: bool,
	z_filter_proc_dev: f64,
	roll_filter_proc_dev: f64,
	pitch_filter_proc_dev: f64,
	proc_stddev_yaw_c: f64,
	proc_stddev_vx_c: f64,
	proc_stddev_wz_c: f64,
	dim_x: i32,
	dim_y_twist: i32,
	twist_gate_dist: f64,
	twist_smoothing_steps: u32,
	twist_additional_delay: f64,
	initial_pose: PoseWithCovariance,
	tf: Transform,
	variable: &'a TECSVariable<TEkfModuleVar>,
}

pub struct TEkfModuleVar{
	pub accumulated_delay_times: [f64; extend_state_step],
	pub ekf_dt: f64,
	pub last_angular_velocity: nalgebra::Vector3<f64>,
	pub z_filter: Simple1DFilter,
	pub roll_filter: Simple1DFilter,
	pub pitch_filter: Simple1DFilter,
}

pub struct EEkfModuleForTEkfModule<'a>{
	pub cell: &'a TEkfModule<'a, EKalmanForTTimeDelayKalmanFilter<'a>, EStateForTStateTransition<'a>, EMeasureForTMeasurement<'a>, EMahaForTMahalanobis<'a>, ECovForTCovariance<'a>, EUtilsForTUtilsGeometry<'a>>,
}

pub struct LockGuardForTEkfModule<'a, T, U, V, W, X, Y>
where
	T: STimeDelayKalmanFilter,
	U: SStateTransition,
	V: SMeasurement,
	W: SMahalanobis,
	X: SCovariance,
	Y: SUtilsGeometry,
{
	pub c_kalman: &'a T,
	pub c_state: &'a U,
	pub c_measure: &'a V,
	pub c_maha: &'a W,
	pub c_cov: &'a X,
	pub c_utils: &'a Y,
	pub extend_state_step: &'a i32,
	pub enable_yaw_bias_estimation: &'a bool,
	pub z_filter_proc_dev: &'a f64,
	pub roll_filter_proc_dev: &'a f64,
	pub pitch_filter_proc_dev: &'a f64,
	pub proc_stddev_yaw_c: &'a f64,
	pub proc_stddev_vx_c: &'a f64,
	pub proc_stddev_wz_c: &'a f64,
	pub dim_x: &'a i32,
	pub dim_y_twist: &'a i32,
	pub twist_gate_dist: &'a f64,
	pub twist_smoothing_steps: &'a u32,
	pub twist_additional_delay: &'a f64,
	pub initial_pose: &'a PoseWithCovariance,
	pub tf: &'a Transform,
	pub var: TECSVarGuard<'a, TEkfModuleVar>,
}

static EKFMODULE: TEkfModule<EKalmanForTTimeDelayKalmanFilter, EStateForTStateTransition, EMeasureForTMeasurement, EMahaForTMahalanobis, ECovForTCovariance, EUtilsForTUtilsGeometry> = TEkfModule {
	c_kalman: &EKALMANFORTIMEDELAYKALMANFILTER,
	c_state: &ESTATEFORSTATETRANSITION,
	c_measure: &EMEASUREFORMEASUREMENT,
	c_maha: &EMAHAFORMAHALANOBIS,
	c_cov: &ECOVFORCOVARIANCE,
	c_utils: &EUTILSFORUTILSGEOMETRY,
	extend_state_step: 50,
	enable_yaw_bias_estimation: true,
	z_filter_proc_dev: 5.0,
	roll_filter_proc_dev: 0.1,
	pitch_filter_proc_dev: 0.1,
	proc_stddev_yaw_c: 0.005,
	proc_stddev_vx_c: 10.0,
	proc_stddev_wz_c: 5.0,
	dim_x: 6,
	dim_y_twist: 2,
	twist_gate_dist: 46.1,
	twist_smoothing_steps: 2,
	twist_additional_delay: 0.0,
	initial_pose: PoseWithCovariance { pose: Pose { point: nalgebra::Vector3::new(1, 1, 1), orientation: nalgebra::Quaternion::new(1, 2, 3, 4), }, covariance: nalgebra::Matrix6::new( 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ) };,
	tf: Transform { translation: nalgebra::Vector3::new(1, 1, 1), rotation: nalgebra::Quaternion::new(1, 2, 3, 4), };,
	variable: &EKFMODULEVAR,
};

static EKFMODULEVAR: TECSVariable<TEkfModuleVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TEkfModuleVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		accumulated_delay_times: [0.0],
		ekf_dt: 0,
		last_angular_velocity: Default::default(),
		z_filter: [0.0, 0.0],
		roll_filter: [0.0, 0.0],
		pitch_filter: [0.0, 0.0],
	}
));
pub static EEKFMODULEFOREKFMODULE: EEkfModuleForTEkfModule = EEkfModuleForTEkfModule {
	cell: &EKFMODULE,
};

impl<'a, T: STimeDelayKalmanFilter, U: SStateTransition, V: SMeasurement, W: SMahalanobis, X: SCovariance, Y: SUtilsGeometry> TEkfModule<'a, T, U, V, W, X, Y> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut awkernel_lib::sync::mutex::MCSNode<TEkfModuleVar>) -> LockGuardForTEkfModule<'_, T, U, V, W, X, Y>
	where
		'b: 'a,
	{
		LockGuardForTEkfModule {
			c_kalman: self.c_kalman,
			c_state: self.c_state,
			c_measure: self.c_measure,
			c_maha: self.c_maha,
			c_cov: self.c_cov,
			c_utils: self.c_utils,
			extend_state_step: &self.extend_state_step,
			enable_yaw_bias_estimation: &self.enable_yaw_bias_estimation,
			z_filter_proc_dev: &self.z_filter_proc_dev,
			roll_filter_proc_dev: &self.roll_filter_proc_dev,
			pitch_filter_proc_dev: &self.pitch_filter_proc_dev,
			proc_stddev_yaw_c: &self.proc_stddev_yaw_c,
			proc_stddev_vx_c: &self.proc_stddev_vx_c,
			proc_stddev_wz_c: &self.proc_stddev_wz_c,
			dim_x: &self.dim_x,
			dim_y_twist: &self.dim_y_twist,
			twist_gate_dist: &self.twist_gate_dist,
			twist_smoothing_steps: &self.twist_smoothing_steps,
			twist_additional_delay: &self.twist_additional_delay,
			initial_pose: &self.initial_pose,
			tf: &self.tf,
			var: self.variable.lock(node),
		}
	}
}
