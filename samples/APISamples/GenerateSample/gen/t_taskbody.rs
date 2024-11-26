use crate::{s_motor::*, t_motor::*, s_sensor::*, t_sensor::*};

pub struct TTaskbody<'a, T, U, V>
where
	T: SMotor,
	U: SMotor,
	V: SSensor,
{
	c_motor_a: &'a T,
	c_motor_b: &'a U,
	c_sensor: &'a V,
}

pub struct ETaskbodyForTTaskbody<'a>{
	pub cell: &'a TTaskbody<'a, EMotorForTMotor<'a>, EMotorForTMotor<'a>, ESensorForTSensor<'a>>,
}

#[link_section = ".rodata"]
pub static TASKBODY: TTaskbody<EMotorForTMotor, EMotorForTMotor, ESensorForTSensor> = TTaskbody {
	c_motor_a: &EMOTORFORMOTORA,
	c_motor_b: &EMOTORFORMOTORB,
	c_sensor: &ESENSORFORSENSOR,
};

#[link_section = ".rodata"]
pub static ETASKBODYFORTASKBODY: ETaskbodyForTTaskbody = ETaskbodyForTTaskbody {
	cell: &TASKBODY,
};

impl<T: SMotor, U: SMotor, V: SSensor> TTaskbody<'_, T, U, V> {
	pub fn get_cell_ref(&'static self) -> (&'static T, &'static U, &'static V) {
		(
			self.c_motor_a,
			self.c_motor_b,
			self.c_sensor
		)
	}
}
