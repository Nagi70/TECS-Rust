use spin::Mutex;
pub struct TCarol<'a>
{
	pub id: i32,
	pub variable: &'a Mutex<TCarolVar>,
}

pub struct TCarolVar{
	pub count: i32,
}

pub struct ECarolForTCarol<'a>{
	pub cell: &'a TCarol<'a>,
}

#[link_section = ".rodata"]
pub static CAROL1: TCarol = TCarol {
	id: 1,
	variable: &CAROL1VAR,
};

pub static CAROL1VAR: Mutex<TCarolVar> = Mutex::new(TCarolVar {
	count: 0,
});

#[link_section = ".rodata"]
pub static ECAROLFORCAROL1: ECarolForTCarol = ECarolForTCarol {
	cell: &CAROL1,
};

#[link_section = ".rodata"]
pub static CAROL2: TCarol = TCarol {
	id: 2,
	variable: &CAROL2VAR,
};

pub static CAROL2VAR: Mutex<TCarolVar> = Mutex::new(TCarolVar {
	count: 0,
});

#[link_section = ".rodata"]
pub static ECAROLFORCAROL2: ECarolForTCarol = ECarolForTCarol {
	cell: &CAROL2,
};

impl TCarol<'_> {
	pub fn get_cell_ref(&self) -> (&i32, &Mutex<TCarolVar>) {
		(&self.id, &self.variable)
	}
}
