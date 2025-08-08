use crate::tecs_signature::s_reactorbody::*;
use crate::tecs_celltype::t_dummy_imu_corrector::*;
pub struct TDagSinkReactor<'a, T>
where
	T: SReactorbody,
{
	c_dag_sink_reactorbody: &'a T,
}

pub struct LockGuardForTDagSinkReactor<'a, T>
where
	T: SReactorbody,
{
	pub c_dag_sink_reactorbody: &'a T,
}

static DUMMYSINKREACTOR: TDagSinkReactor<EDummyImuCorrectorForTDummyImuCorrector> = TDagSinkReactor {
	c_dag_sink_reactorbody: &EDUMMYIMUCORRECTORFORDUMMYIMUCORRECTOR,
};

