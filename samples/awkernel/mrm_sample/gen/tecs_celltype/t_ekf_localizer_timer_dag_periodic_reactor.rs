use crate::tecs_signature::s_ekf_localizer_timer::*;
use crate::tecs_celltype::t_ekf_localizer_timer::*;
pub struct TEkfLocalizerTimerDagPeriodicReactor<T>
where
	T: SEkfLocalizerTimer + 'static,
{
	pub c_dag_periodic_reactor: &'static T,
}

pub struct LockGuardForTEkfLocalizerTimerDagPeriodicReactor<'a, T>
where
	T: SEkfLocalizerTimer + 'static,
{
	pub c_dag_periodic_reactor: &'a T,
}

pub static EKFLOCALIZERTIMERDAGPERIODICREACTOR: TEkfLocalizerTimerDagPeriodicReactor<EReactorForTEkfLocalizerTimer> = TEkfLocalizerTimerDagPeriodicReactor {
	c_dag_periodic_reactor: &EREACTORFOREKFLOCALIZERTIMER,
};

