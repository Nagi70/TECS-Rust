use spin::Mutex;
pub struct TMotorB<'a>
{
	pub port: pbio_port_id_t,
	pub variable: &'a Mutex<TMotorBVar<'a>>,
}

pub struct TMotorBVar<'a>{
	pub motor: Option<&'a mut pup_motor_t>,
}

pub struct EMotorForTMotorB<'a>{
	pub cell: &'a TMotorB<'a>,
}

#[link_section = ".rodata"]
pub static MOTORB: TMotorB = TMotorB {
	port: pbio_port_id_t::PBIO_PORT_ID_B,
	variable: &MOTORBVAR,
};

pub static MOTORBVAR: Mutex<TMotorBVar> = Mutex::new(TMotorBVar {
	motor: None,
});

#[link_section = ".rodata"]
pub static EMOTORFORMOTORB: EMotorForTMotorB = EMotorForTMotorB {
	cell: &MOTORB,
};

impl<'a, > TMotorB<'a> {
	#[inline]
	pub fn get_cell_ref<'a>(&self) -> (&pbio_port_id_t, &Mutex<TMotorBVar<'a>>) {
		(&self.port, &self.variable)
	}
}
