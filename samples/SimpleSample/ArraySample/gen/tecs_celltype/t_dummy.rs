pub struct TDummy{
}

pub struct EReactorForTDummy<'a>{
	pub cell: &'a TDummy,
}

pub struct EIntForTDummy<'a>{
	pub cell: &'a TDummy,
}

static DUMMY: TDummy = TDummy {
};

pub static EREACTORFORDUMMY: EReactorForTDummy = EReactorForTDummy {
	cell: &DUMMY,
};

pub static EINTFORDUMMY: EIntForTDummy = EIntForTDummy {
	cell: &DUMMY,
};

