use crate::tecs_global::*;
use crate::tecs_signature::{s_control::*, s_utils_trajectory::*, s_utils_pose_deviation::*};

use crate::tecs_celltype::{t_dummy_sink_reactor_in_mrm::*, t_utils_trajectory::*, t_utils_pose_deviation::*};

pub struct TTrajectoryFollower<T, U>
where
	T: SUtilsTrajectory + 'static,
	U: SUtilsPoseDeviation + 'static,
{
	c_traj: &'static T,
	c_pose: &'static U,
	use_external_target_vel: bool,
	external_target_vel: f64,
	lateral_deviation: f64,
	wheel_base: f64,
	lookahead_time: f64,
	min_lookahead: f64,
	steer_lim: f64,
	kp_longitudinal: f64,
	acc_lim: f64,
	fix_points: heapless::Vec<TrajectoryPoint, 10>,
}

pub struct EKinematicStateSfForTTrajectoryFollower {
	pub cell: &'static TTrajectoryFollower<EUtilsForTUtilsTrajectory, EUtilsForTUtilsPoseDeviation>,
}

pub struct EAccelForTTrajectoryFollower {
	pub cell: &'static TTrajectoryFollower<EUtilsForTUtilsTrajectory, EUtilsForTUtilsPoseDeviation>,
}

pub struct EReactorForTTrajectoryFollower {
	pub cell: &'static TTrajectoryFollower<EUtilsForTUtilsTrajectory, EUtilsForTUtilsPoseDeviation>,
}

pub struct LockGuardForTTrajectoryFollower<'a, T, U>
where
	T: SUtilsTrajectory + 'static,
	U: SUtilsPoseDeviation + 'static,
{
	pub c_traj: &'a T,
	pub c_pose: &'a U,
	pub use_external_target_vel: &'a bool,
	pub external_target_vel: &'a f64,
	pub lateral_deviation: &'a f64,
	pub wheel_base: &'a f64,
	pub lookahead_time: &'a f64,
	pub min_lookahead: &'a f64,
	pub steer_lim: &'a f64,
	pub kp_longitudinal: &'a f64,
	pub acc_lim: &'a f64,
	pub fix_points: &'a heapless::Vec<TrajectoryPoint, 10>,
}

static TRAJECTORYFOLLOWER: TTrajectoryFollower<EUtilsForTUtilsTrajectory, EUtilsForTUtilsPoseDeviation> = TTrajectoryFollower {
	c_traj: &EUTILSFORUTILSTRAJECTORY,
	c_pose: &EUTILSFORUTILSPOSEDEVIATION,
	use_external_target_vel: true,
	external_target_vel: 5.0,
	lateral_deviation: 0.0,
	wheel_base: 4.0,
	lookahead_time: 3.0,
	min_lookahead: 3.0,
	steer_lim: 0.6,
	kp_longitudinal: 0.5,
	acc_lim: 2.0,
	fix_points: heapless::Vec::new(),
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

impl<T: SUtilsTrajectory, U: SUtilsPoseDeviation> TTrajectoryFollower<T, U> {
	#[inline]
	pub fn get_cell_ref(&'static self) -> LockGuardForTTrajectoryFollower<T, U> {
		LockGuardForTTrajectoryFollower {
			c_traj: self.c_traj,
			c_pose: self.c_pose,
			use_external_target_vel: &self.use_external_target_vel,
			external_target_vel: &self.external_target_vel,
			lateral_deviation: &self.lateral_deviation,
			wheel_base: &self.wheel_base,
			lookahead_time: &self.lookahead_time,
			min_lookahead: &self.min_lookahead,
			steer_lim: &self.steer_lim,
			kp_longitudinal: &self.kp_longitudinal,
			acc_lim: &self.acc_lim,
			fix_points: &self.fix_points,
		}
	}
}
