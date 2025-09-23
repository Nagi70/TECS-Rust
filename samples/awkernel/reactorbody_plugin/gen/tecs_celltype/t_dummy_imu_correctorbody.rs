use crate::tecs_struct_def::*;
pub struct TDummyImuCorrectorbody{
}

pub struct EImuRawForTDummyImuCorrectorbody<'a>{
	pub cell: &'a TDummyImuCorrectorbody,
}

pub struct EReactorForTDummyImuCorrectorbody<'a>{
	pub cell: &'a TDummyImuCorrectorbody,
}

pub struct LockGuardForTDummyImuCorrectorbody<'a>{
}

static DUMMYIMUCORRECTORBODY: TDummyImuCorrectorbody = TDummyImuCorrectorbody {
};

pub static EIMURAWFORDUMMYIMUCORRECTORBODY: EImuRawForTDummyImuCorrectorbody = EImuRawForTDummyImuCorrectorbody {
	cell: &DUMMYIMUCORRECTORBODY,
};

pub static EREACTORFORDUMMYIMUCORRECTORBODY: EReactorForTDummyImuCorrectorbody = EReactorForTDummyImuCorrectorbody {
	cell: &DUMMYIMUCORRECTORBODY,
};

impl<'a> TDummyImuCorrectorbody {
	#[inline]
	pub fn get_cell_ref(&'a self) -> LockGuardForTDummyImuCorrectorbody	{
		LockGuardForTDummyImuCorrectorbody {
		}
	}
}
