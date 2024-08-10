use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{s_hello::*, t_alice::*};

pub struct TCarol<'a, T>
where
	T: SHello,
{
	c_person: &'a T,
	carol_attr: i32,
}

pub struct ECarolForTCarol<'a>{
	pub cell: &'a TCarol<'a, EAliceForTAlice<'a>>,
}

#[link_section = ".rodata"]
pub static CAROL: TCarol<EAliceForTAlice> = TCarol {
	c_person: &EALICEFORALICE2,
	carol_attr: 4,
};

#[link_section = ".rodata"]
pub static ECAROLFORCAROL: ECarolForTCarol = ECarolForTCarol {
	cell: &CAROL,
};

impl<T: SHello> TCarol<'_, T> {
	pub fn get_cell_ref(&'static self) -> (&T, &i32) {
		(
			self.c_person,
			&self.carol_attr
		)
	}
}
