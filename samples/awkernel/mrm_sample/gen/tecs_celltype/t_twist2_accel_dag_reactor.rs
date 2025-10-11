use crate::tecs_signature::s_twist2_accel::*;
use crate::tecs_celltype::t_twist2_accel::*;
pub struct TTwist2AccelDagReactor<T>
where
	T: STwist2Accel + 'static,
{
	pub c_dag_reactor: &'static T,
}

pub struct LockGuardForTTwist2AccelDagReactor<'a, T>
where
	T: STwist2Accel + 'static,
{
	pub c_dag_reactor: &'a T,
}

pub static TWIST2ACCELDAGREACTOR: TTwist2AccelDagReactor<EReactorForTTwist2Accel> = TTwist2AccelDagReactor {
	c_dag_reactor: &EREACTORFORTWIST2ACCEL,
};

