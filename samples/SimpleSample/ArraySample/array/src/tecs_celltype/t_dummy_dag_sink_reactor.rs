use crate::tecs_signature::s_dummy::*;
use crate::tecs_celltype::t_dummy::*;
pub struct TDummyDagSinkReactor<'a, T>
where
	T: SDummy,
{
	pub c_dag_sink_reactor: &'a T,
}

pub struct LockGuardForTDummyDagSinkReactor<'a, T>
where
	T: SDummy,
{
	pub c_dag_sink_reactor: &'a T,
}

pub static DUMMYDAGSINKREACTOR: TDummyDagSinkReactor<EReactorForTDummy> = TDummyDagSinkReactor {
	c_dag_sink_reactor: &EREACTORFORDUMMY,
};

