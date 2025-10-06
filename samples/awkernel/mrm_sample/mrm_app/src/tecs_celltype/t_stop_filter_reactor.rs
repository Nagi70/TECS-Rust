use crate::tecs_signature::s_stop_filter::*;
use crate::tecs_celltype::t_stop_filter::*;
pub struct TStopFilterReactor<'a, T>
where
	T: SStopFilter,
{
	pub c_reactor: &'a T,
}

pub struct LockGuardForTStopFilterReactor<'a, T>
where
	T: SStopFilter,
{
	pub c_reactor: &'a T,
}

pub static STOPFILTERREACTOR: TStopFilterReactor<EReactorForTStopFilter> = TStopFilterReactor {
	c_reactor: &EREACTORFORSTOPFILTER,
};

