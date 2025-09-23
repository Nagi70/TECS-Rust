use crate::tecs_signature::s_dummy_imubody::*;
use crate::tecs_celltype::t_dummy_imubody::*;
pub struct TDummyImubodyDagPeriodicReactor<'a, T>
where
	T: SDummyImubody,
{
	pub c_dag_periodic_reactor: &'a T,
}

pub struct LockGuardForTDummyImubodyDagPeriodicReactor<'a, T>
where
	T: SDummyImubody,
{
	pub c_dag_periodic_reactor: &'a T,
}

pub static DUMMYIMUBODYDAGPERIODICREACTOR: TDummyImubodyDagPeriodicReactor<EReactorForTDummyImubody> = TDummyImubodyDagPeriodicReactor {
	c_dag_periodic_reactor: &EREACTORFORDUMMYIMUBODY,
};

