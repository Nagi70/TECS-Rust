use crate::tecs_signature::s_ekf_localizer_timer::*;
use crate::tecs_celltype::t_ekf_localizer_timer::*;
pub struct TEkfLocalizerTimerPeriodicReactor<'a, T>
where
	T: SEkfLocalizerTimer,
{
	pub c_periodic_reactor: &'a T,
}

pub struct LockGuardForTEkfLocalizerTimerPeriodicReactor<'a, T>
where
	T: SEkfLocalizerTimer,
{
	pub c_periodic_reactor: &'a T,
}

pub static EKFLOCALIZERTIMERPERIODICREACTOR: TEkfLocalizerTimerPeriodicReactor<EReactorForTEkfLocalizerTimer> = TEkfLocalizerTimerPeriodicReactor {
	c_periodic_reactor: &EREACTORFOREKFLOCALIZERTIMER,
};

