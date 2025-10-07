use crate::tecs_variable::*;
use crate::tecs_global::*;
use crate::tecs_signature::{s_kinematic_state::*, s_ekf_module::*, s_twist_with_covariance_get::*};

use crate::tecs_celltype::{t_stop_filter::*, t_ekf_module::*, t_twist_with_covariance_aged_object_queue::*};

pub struct TEkfLocalizerTimer<'a, T, U>
where
	T: SEkfModule,
	U: STwistWithCovarianceGet,
{
	c_ekf_module: &'a T,
	c_queue: &'a U,
	ekf_rate: f64,
	pose_smoothing_steps: u32,
	twist_smoothing_steps: u32,
	threshold_observable_velocity_mps: f64,
	variable: &'a TECSVariable<TEkfLocalizerTimerVar>,
}

pub struct TEkfLocalizerTimerVar{
	pub ekf_dt: f64,
	pub last_predict_time: awkernel_lib::time::Time,
}

pub struct EReactorForTEkfLocalizerTimer<'a>{
	pub cell: &'a TEkfLocalizerTimer<'a, EEkfModuleForTEkfModule<'a>, EGetForTTwistWithCovarianceAgedObjectQueue<'a>>,
}

pub struct LockGuardForTEkfLocalizerTimer<'a, T, U>
where
	T: SEkfModule,
	U: STwistWithCovarianceGet,
{
	pub c_ekf_module: &'a T,
	pub c_queue: &'a U,
	pub ekf_rate: &'a f64,
	pub pose_smoothing_steps: &'a u32,
	pub twist_smoothing_steps: &'a u32,
	pub threshold_observable_velocity_mps: &'a f64,
	pub var: TECSVarGuard<'a, TEkfLocalizerTimerVar>,
}

static EKFLOCALIZERTIMER: TEkfLocalizerTimer<EEkfModuleForTEkfModule, EGetForTTwistWithCovarianceAgedObjectQueue> = TEkfLocalizerTimer {
	c_ekf_module: &EEKFMODULEFOREKFMODULE,
	c_queue: &EGETFORTWISTWITHCOVARIANCEQUEUE,
	ekf_rate: 0.01,
	pose_smoothing_steps: 5,
	twist_smoothing_steps: 5,
	threshold_observable_velocity_mps: 0.01,
	variable: &EKFLOCALIZERTIMERVAR,
};

static EKFLOCALIZERTIMERVAR: TECSVariable<TEkfLocalizerTimerVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TEkfLocalizerTimerVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		ekf_dt: 0,
		last_predict_time: Default::default(),
	}
));
pub static EREACTORFOREKFLOCALIZERTIMER: EReactorForTEkfLocalizerTimer = EReactorForTEkfLocalizerTimer {
	cell: &EKFLOCALIZERTIMER,
};

impl<'a, T: SEkfModule, U: STwistWithCovarianceGet> TEkfLocalizerTimer<'a, T, U> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut awkernel_lib::sync::mutex::MCSNode<TEkfLocalizerTimerVar>) -> LockGuardForTEkfLocalizerTimer<'_, T, U>
	where
		'b: 'a,
	{
		LockGuardForTEkfLocalizerTimer {
			c_ekf_module: self.c_ekf_module,
			c_queue: self.c_queue,
			ekf_rate: &self.ekf_rate,
			pose_smoothing_steps: &self.pose_smoothing_steps,
			twist_smoothing_steps: &self.twist_smoothing_steps,
			threshold_observable_velocity_mps: &self.threshold_observable_velocity_mps,
			var: self.variable.lock(node),
		}
	}
}
