use spin::Mutex;
use crate::{s_hello::*, t_deb::*, t_carol::*};

pub struct TAlice<'a>
{
	pub c_person: &'a (dyn SHello + Sync + Send),
	pub id: i32,
	pub variable: &'a Mutex<TAliceVar>,
}

pub struct TAliceVar{
	pub count: i32,
}

pub struct EAlice1ForTAlice<'a>{
	pub cell: &'a TAlice<'a>,
}

pub struct EAlice2ForTAlice<'a>{
	pub cell: &'a TAlice<'a>,
}

#[link_section = ".rodata"]
pub static ALICE1: TAlice = TAlice {
	c_person: &EDEBFORDEB,
	id: 1,
	variable: &ALICE1VAR,
};

pub static ALICE1VAR: Mutex<TAliceVar> = Mutex::new(TAliceVar {
	count: 0,
});

#[link_section = ".rodata"]
pub static EALICE1FORALICE1: EAlice1ForTAlice = EAlice1ForTAlice {
	cell: &ALICE1,
};

#[link_section = ".rodata"]
pub static EALICE2FORALICE1: EAlice2ForTAlice = EAlice2ForTAlice {
	cell: &ALICE1,
};

#[link_section = ".rodata"]
pub static ALICE2: TAlice = TAlice {
	c_person: &ECAROLFORCAROL1,
	id: 2,
	variable: &ALICE2VAR,
};

pub static ALICE2VAR: Mutex<TAliceVar> = Mutex::new(TAliceVar {
	count: 0,
});

#[link_section = ".rodata"]
pub static EALICE1FORALICE2: EAlice1ForTAlice = EAlice1ForTAlice {
	cell: &ALICE2,
};

#[link_section = ".rodata"]
pub static EALICE2FORALICE2: EAlice2ForTAlice = EAlice2ForTAlice {
	cell: &ALICE2,
};

impl TAlice<'_> {
	pub fn get_cell_ref(&self) -> (&dyn SHello, &i32, &Mutex<TAliceVar>) {
		(&self.c_person, &self.id, &self.variable)
	}
}
