use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{s_motor::*, t_motor::*};

pub struct TMotorbody<'a, T>
where
	T: SMotor,
{
	c_motor: &'a T,
}

pub struct EMotorbodyForTMotorbody<'a>{
	pub cell: &'a TMotorbody<'a, EMotorForTMotor<'a>>,
}

#[link_section = ".rodata"]
pub static MOTORBODY: TMotorbody<EMotorForTMotor> = TMotorbody {
	c_motor: &EMOTORFORMOTOR2,
};

#[link_section = ".rodata"]
pub static EMOTORBODYFORMOTORBODY: EMotorbodyForTMotorbody = EMotorbodyForTMotorbody {
	cell: &MOTORBODY,
};

impl<T: SMotor> TMotorbody<'_, T> {
	pub fn get_cell_ref(&'static self) -> &T {
		self.c_motor
	}
}
