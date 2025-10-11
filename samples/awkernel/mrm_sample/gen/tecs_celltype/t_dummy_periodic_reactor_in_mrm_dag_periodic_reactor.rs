use crate::tecs_signature::s_dummy_periodic_reactor_in_mrm::*;
use crate::tecs_celltype::t_dummy_periodic_reactor_in_mrm::*;
pub struct TDummyPeriodicReactorInMrmDagPeriodicReactor<T>
where
	T: SDummyPeriodicReactorInMrm + 'static,
{
	pub c_dag_periodic_reactor: &'static T,
}

pub struct LockGuardForTDummyPeriodicReactorInMrmDagPeriodicReactor<'a, T>
where
	T: SDummyPeriodicReactorInMrm + 'static,
{
	pub c_dag_periodic_reactor: &'a T,
}

pub static DUMMYHARDWAREDAGPERIODICREACTOR: TDummyPeriodicReactorInMrmDagPeriodicReactor<EReactorForTDummyPeriodicReactorInMrm> = TDummyPeriodicReactorInMrmDagPeriodicReactor {
	c_dag_periodic_reactor: &EREACTORFORDUMMYHARDWARE,
};

