use crate::tecs_signature::s_stop_filter::*;
use crate::tecs_celltype::t_stop_filter::*;
pub struct TStopFilterDagReactor<T>
where
	T: SStopFilter + 'static,
{
	pub c_dag_reactor: &'static T,
}

pub struct LockGuardForTStopFilterDagReactor<'a, T>
where
	T: SStopFilter + 'static,
{
	pub c_dag_reactor: &'a T,
}

pub static STOPFILTERDAGREACTOR: TStopFilterDagReactor<EReactorForTStopFilter> = TStopFilterDagReactor {
	c_dag_reactor: &EREACTORFORSTOPFILTER,
};

