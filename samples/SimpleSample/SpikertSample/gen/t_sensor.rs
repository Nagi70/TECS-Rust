use spin::Mutex;
use crate::{s_powerdown_s::*, t_powerdown::*};

pub struct TSensor<'a, T>
where
	T: SPowerdownS,
{
	pub c_powerdown: &'a T,
	pub port: pbio_port_id_t,
	pub variable: &'a Mutex<TSensorVar<'a>>,
}

pub struct TSensorVar<'a>{
	pub ult: Option<&'a mut pup_ultrasonic_sensor_t>,
}

pub struct ESensorForTSensor<'a>{
	pub cell: &'a TSensor<'a, EPowerdownSForTPowerdown<'a>>,
}

#[link_section = ".rodata"]
pub static SENSOR: TSensor<EPowerdownSForTPowerdown> = TSensor {
	c_powerdown: &EPOWERDOWNSFORPOWERDOWN,
	port: pbio_port_id_t::PBIO_PORT_ID_B,
	variable: &SENSORVAR,
};

pub static SENSORVAR: Mutex<TSensorVar> = Mutex::new(TSensorVar {
	ult: None,
});

#[link_section = ".rodata"]
pub static ESENSORFORSENSOR: ESensorForTSensor = ESensorForTSensor {
	cell: &SENSOR,
};

impl<'a, T: SPowerdownS> TSensor<'a, T> {
	#[inline]
	pub fn get_cell_ref<'a>(&self) -> (&T, &pbio_port_id_t, &Mutex<TSensorVar<'a>>) {
		(self.c_powerdown, &self.port, &self.variable)
	}
}
