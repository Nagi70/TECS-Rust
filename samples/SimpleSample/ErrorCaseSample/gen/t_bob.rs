use crate::{s_hello::*, t_alice::*};

pub struct TBob<'a, T>
where
	T: SHello,
{
	pub c_person: &'a T,
	pub bob_attr: i32,
}

pub struct EBobForTBob<'a>{
	pub cell: &'a TBob<'a, EAliceForTAlice<'a>>,
}

#[link_section = ".rodata"]
pub static BOB: TBob<EAliceForTAlice> = TBob {
	c_person: &EALICEFORALICE1,
	bob_attr: 3,
};

#[link_section = ".rodata"]
pub static EBOBFORBOB: EBobForTBob = EBobForTBob {
	cell: &BOB,
};

impl<T: SHello> TBob<'_, T> {
	pub fn get_cell_ref(&self) -> (&T, &i32) {
		(&self.c_person, &self.bob_attr)
	}
}
