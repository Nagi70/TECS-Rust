use spin::Mutex;
use crate::{s_hello::*, t_carol::*};

pub struct TBob<'a, T>
where
	T: SHello,
{
	pub c_carol: &'a T,
	pub id: i32,
	pub variable: &'a Mutex<TBobVar>,
}

pub struct TBobVar{
	pub count: i32,
}

pub struct EBobForTBob<'a>{
	pub cell: &'a TBob<'a, ECarolForTCarol<'a>>,
}

#[link_section = ".rodata"]
pub static BOB: TBob<ECarolForTCarol> = TBob {
	c_carol: &ECAROLFORCAROL2,
	id: 0,
	variable: &BOBVAR,
};

pub static BOBVAR: Mutex<TBobVar> = Mutex::new(TBobVar {
	count: 0,
});

#[link_section = ".rodata"]
pub static EBOBFORBOB: EBobForTBob = EBobForTBob {
	cell: &BOB,
};

impl<T: SHello> TBob<'_, T> {
	pub fn get_cell_ref(&self) -> (&T, &i32, &Mutex<TBobVar) {
		(&self.c_carol, &self.id, &self.variable)
	}
}
