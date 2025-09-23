use crate::tecs_signature::s_dummy_imu_correctorbody::*;
use crate::tecs_celltype::t_dummy_imu_correctorbody::*;
pub struct TDummyImuCorrectorbodyDagSinkReactor<'a, T>
where
	T: SDummyImuCorrectorbody,
{
	pub c_dag_sink_reactor: &'a T,
}

pub struct LockGuardForTDummyImuCorrectorbodyDagSinkReactor<'a, T>
where
	T: SDummyImuCorrectorbody,
{
	pub c_dag_sink_reactor: &'a T,
}

pub static DUMMYIMUCORRECTORBODYDAGSINKREACTOR: TDummyImuCorrectorbodyDagSinkReactor<EReactorForTDummyImuCorrectorbody> = TDummyImuCorrectorbodyDagSinkReactor {
	c_dag_sink_reactor: &EREACTORFORDUMMYIMUCORRECTORBODY,
};

