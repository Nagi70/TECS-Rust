use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{s_hello::*, t_bob::*, t_carol::*};

pub struct TAlice<'a>
{
	c_person: &'a (dyn SHello + Sync + Send),
	alice_attr: i32,
}

pub struct EAliceForTAlice<'a>{
	pub cell: &'a TAlice<'a>,
}

#[link_section = ".rodata"]
pub static ALICE1: TAlice = TAlice {
	c_person: &EBOBFORBOB,
	alice_attr: 1,
};

#[link_section = ".rodata"]
pub static EALICEFORALICE1: EAliceForTAlice = EAliceForTAlice {
	cell: &ALICE1,
};

#[link_section = ".rodata"]
pub static ALICE2: TAlice = TAlice {
	c_person: &ECAROLFORCAROL,
	alice_attr: 2,
};

#[link_section = ".rodata"]
pub static EALICEFORALICE2: EAliceForTAlice = EAliceForTAlice {
	cell: &ALICE2,
};

impl TAlice<'_> {
	pub fn get_cell_ref(&'static self) -> (&dyn SHello, &i32) {
		(
			self.c_person,
			&self.alice_attr
		)
	}
}
