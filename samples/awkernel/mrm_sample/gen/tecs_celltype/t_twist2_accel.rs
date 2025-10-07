use crate::tecs_variable::*;
use crate::tecs_global::*;
use crate::tecs_signature::{s_accel_with_covariance_stamped::*, s_lowpass1d::*};

use crate::tecs_celltype::{t_trajectory_follower::*, t_lowpass_filter1_d::*};

pub struct TTwist2Accel<'a, T, U, V, W, X, Y>
where
	T: SLowpass1d,
	U: SLowpass1d,
	V: SLowpass1d,
	W: SLowpass1d,
	X: SLowpass1d,
	Y: SLowpass1d,
{
	c_filter_alx: &'a T,
	c_filter_aly: &'a U,
	c_filter_alz: &'a V,
	c_filter_aax: &'a W,
	c_filter_aay: &'a X,
	c_filter_aaz: &'a Y,
	variable: &'a TECSVariable<TTwist2AccelVar>,
}

pub struct TTwist2AccelVar{
	pub prev_twist: TwistStamped,
}

pub struct EKinematicStateForTTwist2Accel<'a>{
	pub cell: &'a TTwist2Accel<'a, EFilterForTLowpassFilter1D<'a>, EFilterForTLowpassFilter1D<'a>, EFilterForTLowpassFilter1D<'a>, EFilterForTLowpassFilter1D<'a>, EFilterForTLowpassFilter1D<'a>, EFilterForTLowpassFilter1D<'a>>,
}

pub struct EReactorForTTwist2Accel<'a>{
	pub cell: &'a TTwist2Accel<'a, EFilterForTLowpassFilter1D<'a>, EFilterForTLowpassFilter1D<'a>, EFilterForTLowpassFilter1D<'a>, EFilterForTLowpassFilter1D<'a>, EFilterForTLowpassFilter1D<'a>, EFilterForTLowpassFilter1D<'a>>,
}

pub struct LockGuardForTTwist2Accel<'a, T, U, V, W, X, Y>
where
	T: SLowpass1d,
	U: SLowpass1d,
	V: SLowpass1d,
	W: SLowpass1d,
	X: SLowpass1d,
	Y: SLowpass1d,
{
	pub c_filter_alx: &'a T,
	pub c_filter_aly: &'a U,
	pub c_filter_alz: &'a V,
	pub c_filter_aax: &'a W,
	pub c_filter_aay: &'a X,
	pub c_filter_aaz: &'a Y,
	pub var: TECSVarGuard<'a, TTwist2AccelVar>,
}

static TWIST2ACCEL: TTwist2Accel<EFilterForTLowpassFilter1D, EFilterForTLowpassFilter1D, EFilterForTLowpassFilter1D, EFilterForTLowpassFilter1D, EFilterForTLowpassFilter1D, EFilterForTLowpassFilter1D> = TTwist2Accel {
	c_filter_alx: &EFILTERFORFILTERALX,
	c_filter_aly: &EFILTERFORFILTERALY,
	c_filter_alz: &EFILTERFORFILTERALZ,
	c_filter_aax: &EFILTERFORFILTERAAX,
	c_filter_aay: &EFILTERFORFILTERAAY,
	c_filter_aaz: &EFILTERFORFILTERAAZ,
	variable: &TWIST2ACCELVAR,
};

static TWIST2ACCELVAR: TECSVariable<TTwist2AccelVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TTwist2AccelVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		prev_twist: Default::default(),
	}
));
pub static EKINEMATICSTATEFORTWIST2ACCEL: EKinematicStateForTTwist2Accel = EKinematicStateForTTwist2Accel {
	cell: &TWIST2ACCEL,
};

pub static EREACTORFORTWIST2ACCEL: EReactorForTTwist2Accel = EReactorForTTwist2Accel {
	cell: &TWIST2ACCEL,
};

impl<'a, T: SLowpass1d, U: SLowpass1d, V: SLowpass1d, W: SLowpass1d, X: SLowpass1d, Y: SLowpass1d> TTwist2Accel<'a, T, U, V, W, X, Y> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut awkernel_lib::sync::mutex::MCSNode<TTwist2AccelVar>) -> LockGuardForTTwist2Accel<'_, T, U, V, W, X, Y>
	where
		'b: 'a,
	{
		LockGuardForTTwist2Accel {
			c_filter_alx: self.c_filter_alx,
			c_filter_aly: self.c_filter_aly,
			c_filter_alz: self.c_filter_alz,
			c_filter_aax: self.c_filter_aax,
			c_filter_aay: self.c_filter_aay,
			c_filter_aaz: self.c_filter_aaz,
			var: self.variable.lock(node),
		}
	}
}
