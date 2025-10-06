use crate::tecs_signature::s_trajectory_follower::*;
use crate::tecs_celltype::t_trajectory_follower::*;
pub struct TTrajectoryFollowerSinkReactor<'a, T>
where
	T: STrajectoryFollower,
{
	pub c_sink_reactor: &'a T,
}

pub struct LockGuardForTTrajectoryFollowerSinkReactor<'a, T>
where
	T: STrajectoryFollower,
{
	pub c_sink_reactor: &'a T,
}

pub static TRAJECTORYFOLLOWERSINKREACTOR: TTrajectoryFollowerSinkReactor<EReactorForTTrajectoryFollower> = TTrajectoryFollowerSinkReactor {
	c_sink_reactor: &EREACTORFORTRAJECTORYFOLLOWER,
};

