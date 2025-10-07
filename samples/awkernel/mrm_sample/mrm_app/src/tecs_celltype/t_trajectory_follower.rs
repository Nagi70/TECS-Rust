use crate::tecs_global::*;
pub struct TTrajectoryFollower{
}

pub struct EKinematicStateSfForTTrajectoryFollower<'a>{
	pub cell: &'a TTrajectoryFollower,
}

pub struct EAccelForTTrajectoryFollower<'a>{
	pub cell: &'a TTrajectoryFollower,
}

pub struct EReactorForTTrajectoryFollower<'a>{
	pub cell: &'a TTrajectoryFollower,
}

pub struct LockGuardForTTrajectoryFollower<'a>{
}

static TRAJECTORYFOLLOWER: TTrajectoryFollower = TTrajectoryFollower {
};

pub static EKINEMATICSTATESFFORTRAJECTORYFOLLOWER: EKinematicStateSfForTTrajectoryFollower = EKinematicStateSfForTTrajectoryFollower {
	cell: &TRAJECTORYFOLLOWER,
};

pub static EACCELFORTRAJECTORYFOLLOWER: EAccelForTTrajectoryFollower = EAccelForTTrajectoryFollower {
	cell: &TRAJECTORYFOLLOWER,
};

pub static EREACTORFORTRAJECTORYFOLLOWER: EReactorForTTrajectoryFollower = EReactorForTTrajectoryFollower {
	cell: &TRAJECTORYFOLLOWER,
};

impl<'a> TTrajectoryFollower {
	#[inline]
	pub fn get_cell_ref(&'a self) -> LockGuardForTTrajectoryFollower	{
		LockGuardForTTrajectoryFollower {
		}
	}
}
