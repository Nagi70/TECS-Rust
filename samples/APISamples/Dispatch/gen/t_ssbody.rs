use crate::{s_sensor::*, t_sensor::*};

pub struct TSsbody<'a, T, U>
where
	T: SSensor,
	U: SSensor,
{
	c_sensor1: &'a T,
	c_sensor2: &'a U,
}

pub struct ESsbodyForTSsbody<'a>{
	pub cell: &'a TSsbody<'a, ESensorForTSensor<'a>, ESensorForTSensor<'a>>,
}

#[link_section = ".rodata"]
pub static SSBODY: TSsbody<ESensorForTSensor, ESensorForTSensor> = TSsbody {
	c_sensor1: &ESENSORFORSENSOR1,
	c_sensor2: &ESENSORFORSENSOR2,
};

#[link_section = ".rodata"]
pub static ESSBODYFORSSBODY: ESsbodyForTSsbody = ESsbodyForTSsbody {
	cell: &SSBODY,
};

impl<T: SSensor, U: SSensor> TSsbody<'_, T, U> {
	pub fn get_cell_ref(&'static self) -> (&'static T, &'static U) {
		(
			self.c_sensor1,
			self.c_sensor2
		)
	}
}
