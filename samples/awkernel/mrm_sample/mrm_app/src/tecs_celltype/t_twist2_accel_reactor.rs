use crate::tecs_signature::s_twist2_accel::*;
use crate::tecs_celltype::t_twist2_accel::*;
pub struct TTwist2AccelReactor<'a, T>
where
	T: STwist2Accel,
{
	pub c_reactor: &'a T,
}

pub struct LockGuardForTTwist2AccelReactor<'a, T>
where
	T: STwist2Accel,
{
	pub c_reactor: &'a T,
}

pub static TWIST2ACCELREACTOR: TTwist2AccelReactor<EReactorForTTwist2Accel> = TTwist2AccelReactor {
	c_reactor: &EREACTORFORTWIST2ACCEL,
};

