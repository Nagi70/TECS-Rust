use crate::tecs_struct_def::*;
use crate::tecs_signature::s_twist_with_covariance_set::*;
use crate::tecs_celltype::t_twist_with_covariance_aged_object_queue::*;
pub struct TEkfLocalizer<'a, T>
where
	T: STwistWithCovarianceSet,
{
	c_twist_with_covariance_queue: &'a T,
}

pub struct ETwistWithCovarianceGForTEkfLocalizer<'a>{
	pub cell: &'a TEkfLocalizer<'a, ESetForTTwistWithCovarianceAgedObjectQueue<'a>>,
}

pub struct EReactorForTEkfLocalizer<'a>{
	pub cell: &'a TEkfLocalizer<'a, ESetForTTwistWithCovarianceAgedObjectQueue<'a>>,
}

pub struct LockGuardForTEkfLocalizer<'a, T>
where
	T: STwistWithCovarianceSet,
{
	pub c_twist_with_covariance_queue: &'a T,
}

static EKFLOCALIZER: TEkfLocalizer<ESetForTTwistWithCovarianceAgedObjectQueue> = TEkfLocalizer {
	c_twist_with_covariance_queue: &ESETFORTWISTWITHCOVARIANCEQUEUE,
};

pub static ETWISTWITHCOVARIANCEGFOREKFLOCALIZER: ETwistWithCovarianceGForTEkfLocalizer = ETwistWithCovarianceGForTEkfLocalizer {
	cell: &EKFLOCALIZER,
};

pub static EREACTORFOREKFLOCALIZER: EReactorForTEkfLocalizer = EReactorForTEkfLocalizer {
	cell: &EKFLOCALIZER,
};

impl<'a, T: STwistWithCovarianceSet> TEkfLocalizer<'a, T> {
	#[inline]
	pub fn get_cell_ref(&'a self) -> LockGuardForTEkfLocalizer<'_, T>	{
		LockGuardForTEkfLocalizer {
			c_twist_with_covariance_queue: self.c_twist_with_covariance_queue,
		}
	}
}
