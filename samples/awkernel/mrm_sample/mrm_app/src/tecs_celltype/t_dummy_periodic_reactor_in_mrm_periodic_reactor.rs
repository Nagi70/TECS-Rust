use crate::tecs_signature::s_dummy_periodic_reactor_in_mrm::*;
use crate::tecs_celltype::t_dummy_periodic_reactor_in_mrm::*;
pub struct TDummyPeriodicReactorInMrmPeriodicReactor<'a, T>
where
	T: SDummyPeriodicReactorInMrm,
{
	pub c_periodic_reactor: &'a T,
}

pub struct LockGuardForTDummyPeriodicReactorInMrmPeriodicReactor<'a, T>
where
	T: SDummyPeriodicReactorInMrm,
{
	pub c_periodic_reactor: &'a T,
}

pub static DUMMYHARDWAREPERIODICREACTOR: TDummyPeriodicReactorInMrmPeriodicReactor<EReactorForTDummyPeriodicReactorInMrm> = TDummyPeriodicReactorInMrmPeriodicReactor {
	c_periodic_reactor: &EREACTORFORDUMMYHARDWARE,
};

