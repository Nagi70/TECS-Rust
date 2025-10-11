use crate::tecs_global::*;
use crate::tecs_signature::s_twist_with_covariance_set::*;
use crate::tecs_celltype::t_twist_with_covariance_aged_object_queue::*;
pub struct TEkfLocalizer<T>
where
	T: STwistWithCovarianceSet + 'static,
{
	c_twist_with_covariance_queue: &'static T,
	threshold_observable_velocity_mps: f64,
}

pub struct ETwistWithCovarianceGForTEkfLocalizer {
	pub cell: &'static TEkfLocalizer<ESetForTTwistWithCovarianceAgedObjectQueue>,
}

pub struct EReactorForTEkfLocalizer {
	pub cell: &'static TEkfLocalizer<ESetForTTwistWithCovarianceAgedObjectQueue>,
}

pub struct LockGuardForTEkfLocalizer<'a, T>
where
	T: STwistWithCovarianceSet + 'static,
{
	pub c_twist_with_covariance_queue: &'a T,
	pub threshold_observable_velocity_mps: &'a f64,
}

static EKFLOCALIZER: TEkfLocalizer<ESetForTTwistWithCovarianceAgedObjectQueue> = TEkfLocalizer {
	c_twist_with_covariance_queue: &ESETFORTWISTWITHCOVARIANCEQUEUE,
	threshold_observable_velocity_mps: 0.1,
};

pub static ETWISTWITHCOVARIANCEGFOREKFLOCALIZER: ETwistWithCovarianceGForTEkfLocalizer = ETwistWithCovarianceGForTEkfLocalizer {
	cell: &EKFLOCALIZER,
};

pub static EREACTORFOREKFLOCALIZER: EReactorForTEkfLocalizer = EReactorForTEkfLocalizer {
	cell: &EKFLOCALIZER,
};

impl<T: STwistWithCovarianceSet> TEkfLocalizer<T> {
	#[inline]
	pub fn get_cell_ref(&'static self) -> LockGuardForTEkfLocalizer<T> {
		LockGuardForTEkfLocalizer {
			c_twist_with_covariance_queue: self.c_twist_with_covariance_queue,
			threshold_observable_velocity_mps: &self.threshold_observable_velocity_mps,
		}
	}
}
