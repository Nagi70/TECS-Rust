use crate::tecs_variable::*;
use crate::tecs_global::*;
use crate::tecs_signature::{s_kinematic_state::*, s_ekf_module::*, s_twist_with_covariance_get::*};

use crate::tecs_celltype::{t_stop_filter::*, t_ekf_module::*, t_twist_with_covariance_aged_object_queue::*};

pub struct TEkfLocalizerTimer<T, U>
where
	T: SEkfModule + 'static,
	U: STwistWithCovarianceGet + 'static,
{
	c_ekf_module: &'static T,
	c_queue: &'static U,
	ekf_rate: f64,
	pose_smoothing_steps: u32,
	twist_smoothing_steps: u32,
	variable: &'static TECSVariable<TEkfLocalizerTimerVar>,
}

pub struct TEkfLocalizerTimerVar {
	pub ekf_dt: f64,
	pub last_predict_time: awkernel_lib::time::Time,
}

pub struct EReactorForTEkfLocalizerTimer {
	pub cell: &'static TEkfLocalizerTimer<EEkfModuleForTEkfModule, EGetForTTwistWithCovarianceAgedObjectQueue>,
}

pub struct LockGuardForTEkfLocalizerTimer<'a, T, U>
where
	T: SEkfModule + 'static,
	U: STwistWithCovarianceGet + 'static,
{
	pub c_ekf_module: &'a T,
	pub c_queue: &'a U,
	pub ekf_rate: &'a f64,
	pub pose_smoothing_steps: &'a u32,
	pub twist_smoothing_steps: &'a u32,
	pub var: TECSVarGuard<'a, TEkfLocalizerTimerVar>,
}

static EKFLOCALIZERTIMER: TEkfLocalizerTimer<EEkfModuleForTEkfModule, EGetForTTwistWithCovarianceAgedObjectQueue> = TEkfLocalizerTimer {
	c_ekf_module: &EEKFMODULEFOREKFMODULE,
	c_queue: &EGETFORTWISTWITHCOVARIANCEQUEUE,
	ekf_rate: 0.01,
	pose_smoothing_steps: 5,
	twist_smoothing_steps: 5,
	variable: &EKFLOCALIZERTIMERVAR,
};

static EKFLOCALIZERTIMERVAR: TECSVariable<TEkfLocalizerTimerVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TEkfLocalizerTimerVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
	ekf_dt: 0,
	last_predict_time: awkernel_lib::time::Time::zero(),
	}
));
pub static EREACTORFOREKFLOCALIZERTIMER: EReactorForTEkfLocalizerTimer = EReactorForTEkfLocalizerTimer {
	cell: &EKFLOCALIZERTIMER,
};

impl<T: SEkfModule, U: STwistWithCovarianceGet> TEkfLocalizerTimer<T, U> {
	#[inline]
	pub fn get_cell_ref<'node>(&'static self, node: &'node mut awkernel_lib::sync::mutex::MCSNode<TEkfLocalizerTimerVar>) -> LockGuardForTEkfLocalizerTimer<'node, T, U> {
		LockGuardForTEkfLocalizerTimer {
			c_ekf_module: self.c_ekf_module,
			c_queue: self.c_queue,
			ekf_rate: &self.ekf_rate,
			pose_smoothing_steps: &self.pose_smoothing_steps,
			twist_smoothing_steps: &self.twist_smoothing_steps,
			var: self.variable.lock(node),
		}
	}
}
