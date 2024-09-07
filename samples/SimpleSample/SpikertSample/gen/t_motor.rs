use spin::Mutex;
use crate::{s_powerdown_m::*, t_powerdown::*};

pub struct TMotor<'a, T>
where
	T: SPowerdownM,
{
	pub c_powerdown: &'a T,
	pub port: pbio_port_id_t,
	pub variable: &'a Mutex<TMotorVar<'a>>,
}

pub struct TMotorVar<'a>{
	pub motor: Option<&'a mut pup_motor_t>,
}

pub struct EMotorForTMotor<'a>{
	pub cell: &'a TMotor<'a, EPowerdownMForTPowerdown<'a>>,
}

#[link_section = ".rodata"]
pub static MOTOR: TMotor<EPowerdownMForTPowerdown> = TMotor {
	c_powerdown: &EPOWERDOWNMFORPOWERDOWN,
	port: pbio_port_id_t::PBIO_PORT_ID_A,
	variable: &MOTORVAR,
};

pub static MOTORVAR: Mutex<TMotorVar> = Mutex::new(TMotorVar {
	motor: None,
});

#[link_section = ".rodata"]
pub static EMOTORFORMOTOR: EMotorForTMotor = EMotorForTMotor {
	cell: &MOTOR,
};

impl<'a, T: SPowerdownM> TMotor<'a, T> {
	#[inline]
	pub fn get_cell_ref<'a>(&self) -> (&T, &pbio_port_id_t, &Mutex<TMotorVar<'a>>) {
		(self.c_powerdown, &self.port, &self.variable)
	}
}
