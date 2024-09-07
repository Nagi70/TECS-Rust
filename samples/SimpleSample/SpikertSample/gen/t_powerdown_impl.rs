use crate::{t_powerdown::*, s_powerdown_m::*, s_powerdown_s::*};

impl SPowerdownM for EPowerdownMForTPowerdown<'_>{

	#[inline]
	fn powerdown<'a>(&self, motor: &Option<&'a mut pup_motor_t>) {

	}
}

impl SPowerdownS for EPowerdownSForTPowerdown<'_>{

	#[inline]
	fn powerdown<'a>(&self, ult: &Option<&'a mut pup_ultrasonic_sensor_t>) {

	}
}

