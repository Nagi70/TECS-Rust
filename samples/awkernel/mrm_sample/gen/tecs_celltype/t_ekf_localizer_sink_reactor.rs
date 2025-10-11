use crate::tecs_signature::s_ekf_localizer::*;
use crate::tecs_celltype::t_ekf_localizer::*;
pub struct TEkfLocalizerSinkReactor<T>
where
	T: SEkfLocalizer + 'static,
{
	pub c_sink_reactor: &'static T,
}

pub struct LockGuardForTEkfLocalizerSinkReactor<'a, T>
where
	T: SEkfLocalizer + 'static,
{
	pub c_sink_reactor: &'a T,
}

pub static EKFLOCALIZERSINKREACTOR: TEkfLocalizerSinkReactor<EReactorForTEkfLocalizer> = TEkfLocalizerSinkReactor {
	c_sink_reactor: &EREACTORFOREKFLOCALIZER,
};

