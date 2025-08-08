use crate::tecs_signature::s_reactorbody::*;
use crate::tecs_celltype::t_dummy_imu::*;
pub struct TDagPeriodicReactor<'a, T>
where
	T: SReactorbody,
{
	c_dag_periodic_reactorbody: &'a T,
}

pub struct LockGuardForTDagPeriodicReactor<'a, T>
where
	T: SReactorbody,
{
	pub c_dag_periodic_reactorbody: &'a T,
}

static DUMMYPERIODICREACTOR: TDagPeriodicReactor<EDummyImuForTDummyImu> = TDagPeriodicReactor {
	c_dag_periodic_reactorbody: &EDUMMYIMUFORDUMMYIMU,
};

