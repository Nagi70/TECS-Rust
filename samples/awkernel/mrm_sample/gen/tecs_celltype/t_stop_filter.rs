use crate::tecs_global::*;
use crate::tecs_signature::s_kinematic_state::*;
use crate::tecs_celltype::t_trajectory_follower::*;
pub struct TStopFilter{
	vx_threshold: f64,
	wz_threshold: f64,
}

pub struct EKinematicStateForTStopFilter {
	pub cell: &'static TStopFilterstatic STOPFILTER: TStopFilter = TStopFilter {
	vx_threshold: 0.0,
	wz_threshold: 0.0,
};

pub static EKINEMATICSTATEFORSTOPFILTER: EKinematicStateForTStopFilter = EKinematicStateForTStopFilter {
	cell: &STOPFILTER,
};

pub static EREACTORFORSTOPFILTER: EReactorForTStopFilter = EReactorForTStopFilter {
	cell: &STOPFILTER,
};

