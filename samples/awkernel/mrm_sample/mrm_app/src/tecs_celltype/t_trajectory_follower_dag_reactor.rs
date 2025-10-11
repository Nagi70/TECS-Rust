use crate::tecs_signature::s_trajectory_follower::*;
use crate::tecs_celltype::t_trajectory_follower::*;
pub struct TTrajectoryFollowerDagReactor<T>
where
	T: STrajectoryFollower + 'static,
{
	pub c_dag_reactor: &'static T,
}

pub struct LockGuardForTTrajectoryFollowerDagReactor<'a, T>
where
	T: STrajectoryFollower + 'static,
{
	pub c_dag_reactor: &'a T,
}

pub static TRAJECTORYFOLLOWERDAGREACTOR: TTrajectoryFollowerDagReactor<EReactorForTTrajectoryFollower> = TTrajectoryFollowerDagReactor {
	c_dag_reactor: &EREACTORFORTRAJECTORYFOLLOWER,
};

