use crate::{t_powerdown::*, s_powerdown::*};

impl SPowerdown for EPowerdown1ForTPowerdown<'_>{

	#[inline]
	fn powerdown(&self, error: &pbio_error_t) {
		if *error != pbio_error_t::PBIO_SUCCESS {
			unsafe { hub_system_shutdown() };
		}
	}
}

impl SPowerdown for EPowerdown2ForTPowerdown<'_>{

	#[inline]
	fn powerdown(&self, error: &pbio_error_t) {
		if *error != pbio_error_t::PBIO_SUCCESS {
			unsafe { hub_system_shutdown() };
		}
	}
}

