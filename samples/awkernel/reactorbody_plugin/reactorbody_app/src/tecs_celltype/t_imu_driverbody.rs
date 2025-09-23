use crate::tecs_struct_def::*;
use crate::tecs_signature::s_imu_raw::*;
use crate::tecs_celltype::t_dummy_imu_correctorbody::*;
pub struct TImuDriverbody{
}

pub struct EImuForTImuDriverbody<'a>{
	pub cell: &'a TImuDriverbody,
}

pub struct EReactorForTImuDriverbody<'a>{
	pub cell: &'a TImuDriverbody,
}

pub struct LockGuardForTImuDriverbody<'a>{
}

static IMUDRIVERBODY: TImuDriverbody = TImuDriverbody {
};

pub static EIMUFORIMUDRIVERBODY: EImuForTImuDriverbody = EImuForTImuDriverbody {
	cell: &IMUDRIVERBODY,
};

pub static EREACTORFORIMUDRIVERBODY: EReactorForTImuDriverbody = EReactorForTImuDriverbody {
	cell: &IMUDRIVERBODY,
};

impl<'a> TImuDriverbody {
	#[inline]
	pub fn get_cell_ref(&'a self) -> LockGuardForTImuDriverbody	{
		LockGuardForTImuDriverbody {
		}
	}
}
