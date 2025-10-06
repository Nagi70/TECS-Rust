use crate::tecs_struct_def::*;
use crate::tecs_signature::s_kinematic_state::*;
use crate::tecs_celltype::t_trajectory_follower::*;
pub struct TStopFilter{
	vx_threshold: f64,
	wz_threshold: f64,
}

pub struct EKinematicStateForTStopFilter<'a>{
	pub cell: &'a TStopFilter,
}

pub struct EReactorForTStopFilter<'a>{
	pub cell: &'a TStopFilter,
}

pub struct LockGuardForTStopFilter<'a>{
	pub vx_threshold: &'a f64,
	pub wz_threshold: &'a f64,
}

static STOPFILTER: TStopFilter = TStopFilter {
	vx_threshold: 0.0,
	wz_threshold: 0.0,
};

pub static EKINEMATICSTATEFORSTOPFILTER: EKinematicStateForTStopFilter = EKinematicStateForTStopFilter {
	cell: &STOPFILTER,
};

pub static EREACTORFORSTOPFILTER: EReactorForTStopFilter = EReactorForTStopFilter {
	cell: &STOPFILTER,
};

impl<'a> TStopFilter {
	#[inline]
	pub fn get_cell_ref(&'a self) -> LockGuardForTStopFilter	{
		LockGuardForTStopFilter {
			vx_threshold: &self.vx_threshold,
			wz_threshold: &self.wz_threshold,
		}
	}
}
