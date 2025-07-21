use crate::tecs_signature::s_reactorbody::*;
use crate::tecs_celltype::t_camerabody::*;
pub struct TPeriodicReactor<'a, T>
where
	T: SReactorbody,
{
	c_periodic_reactorbody: &'a T,
}

pub struct ETaskForTPeriodicReactor<'a>{
	pub cell: &'a TPeriodicReactor<'a, ECamerabodyForTCamerabody<'a>>,
}

pub struct LockGuardForTPeriodicReactor<'a, T>
where
	T: SReactorbody,
{
	pub c_periodic_reactorbody: &'a T,
}

static PERIODICREACTOR: TPeriodicReactor<ECamerabodyForTCamerabody> = TPeriodicReactor {
	c_periodic_reactorbody: &ECAMERABODYFORCAMERABODY,
};

pub static ETASKFORPERIODICREACTOR: ETaskForTPeriodicReactor = ETaskForTPeriodicReactor {
	cell: &PERIODICREACTOR,
};

impl<T: SReactorbody> TPeriodicReactor<'_, T> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TPeriodicReactor>) -> LockGuardForTPeriodicReactor<'_, T>
	where
		'b: 'a,
	{
		LockGuardForTPeriodicReactor {
			c_periodic_reactorbody: self.c_periodic_reactorbody,
		}
	}
}
