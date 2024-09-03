use spin::Mutex;
pub struct TMotorA<'a>
{
	pub port: pbio_port_id_t,
	pub variable: &'a Mutex<TMotorAVar<'a>>,
}

pub struct TMotorAVar<'a>{
	pub motor: Option<&'a mut pup_motor_t>,
}

pub struct EMotorForTMotorA<'a>{
	pub cell: &'a TMotorA<'a>,
}

#[link_section = ".rodata"]
pub static MOTORA: TMotorA = TMotorA {
	port: pbio_port_id_t::PBIO_PORT_ID_A,
	variable: &MOTORAVAR,
};

pub static MOTORAVAR: Mutex<TMotorAVar> = Mutex::new(TMotorAVar {
	motor: None,
});

#[link_section = ".rodata"]
pub static EMOTORFORMOTORA: EMotorForTMotorA = EMotorForTMotorA {
	cell: &MOTORA,
};

impl<'a, > TMotorA<'a> {
	#[inline]
	pub fn get_cell_ref<'a>(&self) -> (&pbio_port_id_t, &Mutex<TMotorAVar<'a>>) {
		(&self.port, &self.variable)
	}
}
