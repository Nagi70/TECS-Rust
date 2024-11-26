use crate::{s_sensor::*, t_sensor::*};

pub struct TSensorbody<'a, T>
where
	T: SSensor,
{
	c_sensor: &'a T,
}

pub struct ESensorbodyForTSensorbody<'a>{
	pub cell: &'a TSensorbody<'a, ESensorForTSensor<'a>>,
}

#[link_section = ".rodata"]
pub static SENSORBODY: TSensorbody<ESensorForTSensor> = TSensorbody {
	c_sensor: &ESENSORFORSENSOR,
};

#[link_section = ".rodata"]
pub static ESENSORBODYFORSENSORBODY: ESensorbodyForTSensorbody = ESensorbodyForTSensorbody {
	cell: &SENSORBODY,
};

impl<T: SSensor> TSensorbody<'_, T> {
	pub fn get_cell_ref(&'static self) -> &'static T {
		self.c_sensor
	}
}
