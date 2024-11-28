use crate::{s_motor::*, t_motor::*};

pub struct TMmbody<'a, T, U>
where
	T: SMotor,
	U: SMotor,
{
	c_motor1: &'a T,
	c_motor2: &'a U,
}

pub struct EMmbodyForTMmbody<'a>{
	pub cell: &'a TMmbody<'a, EMotorForTMotor<'a>, EMotorForTMotor<'a>>,
}

#[link_section = ".rodata"]
pub static MMBODY: TMmbody<EMotorForTMotor, EMotorForTMotor> = TMmbody {
	c_motor1: &EMOTORFORMOTOR1,
	c_motor2: &EMOTORFORMOTOR2,
};

#[link_section = ".rodata"]
pub static EMMBODYFORMMBODY: EMmbodyForTMmbody = EMmbodyForTMmbody {
	cell: &MMBODY,
};

impl<T: SMotor, U: SMotor> TMmbody<'_, T, U> {
	pub fn get_cell_ref(&'static self) -> (&'static T, &'static U) {
		(
			self.c_motor1,
			self.c_motor2
		)
	}
}
