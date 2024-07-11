use spin::Mutex;
use crate::{s_hello::*, t_carol::*};

pub struct TAlice<'a, T>
where
	T: SHello,
{
	pub c_carol: &'a T,
	pub id: i32,
	pub variable: &'a Mutex<TAliceVar>,
}

pub struct TAliceVar{
	pub count: i32,
}

pub struct EAlice1ForTAlice<'a>{
	pub cell: &'a TAlice<'a, ECarolForTCarol<'a>>,
}

pub struct EAlice2ForTAlice<'a>{
	pub cell: &'a TAlice<'a, ECarolForTCarol<'a>>,
}

#[link_section = ".rodata"]
pub static ALICE: TAlice<ECarolForTCarol> = TAlice {
	c_carol: &ECAROLFORCAROL2,
	id: 0,
	variable: &ALICEVAR,
};

pub static ALICEVAR: Mutex<TAliceVar> = Mutex::new(TAliceVar {
	count: 0,
});

#[link_section = ".rodata"]
pub static EALICE1FORALICE: EAlice1ForTAlice = EAlice1ForTAlice {
	cell: &ALICE,
};

#[link_section = ".rodata"]
pub static EALICE2FORALICE: EAlice2ForTAlice = EAlice2ForTAlice {
	cell: &ALICE,
};

impl<T: SHello> TAlice<'_, T> {
	pub fn get_cell_ref(&self) -> (&T, &i32, &Mutex<TAliceVar) {
		(&self.c_carol, &self.id, &self.variable)
	}
}
