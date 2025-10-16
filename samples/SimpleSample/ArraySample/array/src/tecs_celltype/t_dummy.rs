use crate::tecs_global::*;
pub struct TDummy{
}

pub struct EReactorForTDummy {
	pub cell: &'static TDummy,
}

pub struct EIntForTDummy {
	pub cell: &'static TDummy,
}

static DUMMY: TDummy = TDummy {
};

pub static EREACTORFORDUMMY: EReactorForTDummy = EReactorForTDummy {
	cell: &DUMMY,
};

pub static EINTFORDUMMY: EIntForTDummy = EIntForTDummy {
	cell: &DUMMY,
};

