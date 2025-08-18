pub struct TDummyImuCorrectorbody{
}

pub struct EImuRawForTDummyImuCorrectorbody<'a>{
	pub cell: &'a TDummyImuCorrectorbody,
}

pub struct EDummyImuCorrectorbodyForTDummyImuCorrectorbody<'a>{
	pub cell: &'a TDummyImuCorrectorbody,
}

static DUMMYIMUCORRECTORBODY: TDummyImuCorrectorbody = TDummyImuCorrectorbody {
};

pub static EIMURAWFORDUMMYIMUCORRECTORBODY: EImuRawForTDummyImuCorrectorbody = EImuRawForTDummyImuCorrectorbody {
	cell: &DUMMYIMUCORRECTORBODY,
};

pub static EDUMMYIMUCORRECTORBODYFORDUMMYIMUCORRECTORBODY: EDummyImuCorrectorbodyForTDummyImuCorrectorbody = EDummyImuCorrectorbodyForTDummyImuCorrectorbody {
	cell: &DUMMYIMUCORRECTORBODY,
};

