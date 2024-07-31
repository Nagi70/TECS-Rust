use spin::Mutex;
pub struct TDeb<'a>
{
	pub id: i32,
	pub variable: &'a Mutex<TDebVar>,
}

pub struct TDebVar{
	pub count: i32,
}

pub struct EDebForTDeb<'a>{
	pub cell: &'a TDeb<'a>,
}

#[link_section = ".rodata"]
pub static DEB: TDeb = TDeb {
	id: 0,
	variable: &DEBVAR,
};

pub static DEBVAR: Mutex<TDebVar> = Mutex::new(TDebVar {
	count: 0,
});

#[link_section = ".rodata"]
pub static EDEBFORDEB: EDebForTDeb = EDebForTDeb {
	cell: &DEB,
};

impl TDeb<'_> {
	pub fn get_cell_ref(&self) -> (&i32, &Mutex<TDebVar>) {
		(&self.id, &self.variable)
	}
}
