use crate::{s_hello::*, t_bob::*, t_carol::*};

pub struct TAlice<'a>
{
	pub c_person: &'a (dyn SHello + Sync + Send),
}

pub struct EAliceForTAlice<'a>{
	pub cell: &'a TAlice<'a>,
}

pub static ALICE1: TAlice = TAlice {
	c_person: &EBOBFORBOB,
};

pub static EALICEFORALICE1: EAliceForTAlice = EAliceForTAlice {
	cell: &ALICE1,
};

pub static ALICE2: TAlice = TAlice {
	c_person: &ECAROLFORCAROL,
};

pub static EALICEFORALICE2: EAliceForTAlice = EAliceForTAlice {
	cell: &ALICE2,
};

impl TAlice<'_> {
	pub fn get_cell_ref(&self) -> &dyn SHello {
		&self.c_person
	}
}
