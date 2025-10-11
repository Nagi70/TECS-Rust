use crate::tecs_signature::s_dummy_sink_reactor_in_mrm::*;
use crate::tecs_celltype::t_dummy_sink_reactor_in_mrm::*;
pub struct TDummySinkReactorInMrmDagSinkReactor<T>
where
	T: SDummySinkReactorInMrm + 'static,
{
	pub c_dag_sink_reactor: &'static T,
}

pub struct LockGuardForTDummySinkReactorInMrmDagSinkReactor<'a, T>
where
	T: SDummySinkReactorInMrm + 'static,
{
	pub c_dag_sink_reactor: &'a T,
}

pub static DUMMYSINKREACTORDAGSINKREACTOR: TDummySinkReactorInMrmDagSinkReactor<EReactorForTDummySinkReactorInMrm> = TDummySinkReactorInMrmDagSinkReactor {
	c_dag_sink_reactor: &EREACTORFORDUMMYSINKREACTOR,
};

