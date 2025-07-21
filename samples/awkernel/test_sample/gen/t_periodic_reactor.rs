use itron::task::TaskRef;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{s_periodic_reactorbody::*, t_imu::*, s_pubsub::*, t_pubsub::*};

pub struct TPeriodicReactor<'a, T, U>where
	T: SPeriodicReactorbody,
	U: SPubsub,
{
	c_taskbody: &'a T,
	c_publisher: &'a U,
	name: Cow,
}

pub struct ETaskForTPeriodicReactor<'a>{
	pub cell: &'a TPeriodicReactor<'a, EImuForTImu<'a>, EPubsubForTPubsub<'a>>,
}

pub struct LockGuardForTPeriodicReactor<'a, T, U>where
	T: SPeriodicReactorbody,
	U: SPubsub,
{
	pub c_taskbody: &'a T,
	pub c_publisher: &'a U,
	pub name: &'a Cow,
}

#[link_section = ".rodata"]
pub static PERIODICREACTOR: TPeriodicReactor<EImuForTImu, EPubsubForTPubsub> = TPeriodicReactor {
	c_taskbody: &EIMUFORIMU,
	c_publisher: &EPUBSUBFORTOPIC1,
	name: periodic_reactor,
};

#[link_section = ".rodata"]
pub static ETASKFORPERIODICREACTOR: ETaskForTPeriodicReactor = ETaskForTPeriodicReactor {
	cell: &PERIODICREACTOR,
};

impl<T: SPeriodicReactorbody, U: SPubsub> TPeriodicReactor<'_, T, U> {
	pub fn get_cell_ref(&'static self) -> LockGuardForTPeriodicReactor<'_, T, U> {
		LockGuardForTPeriodicReactor {
			c_taskbody: self.c_taskbody,
			c_publisher: self.c_publisher,
			name: &self.name,
		}
	}
}
