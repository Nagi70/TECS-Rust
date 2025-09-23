use crate::tecs_signature::s_imudriverbody::*;
use crate::tecs_celltype::t_imu_driverbody::*;
pub struct TImuDriverbodyDagReactor<'a, T>
where
	T: SImudriverbody,
{
	pub c_dag_reactor: &'a T,
}

pub struct LockGuardForTImuDriverbodyDagReactor<'a, T>
where
	T: SImudriverbody,
{
	pub c_dag_reactor: &'a T,
}

pub static IMUDRIVERBODYDAGREACTOR: TImuDriverbodyDagReactor<EReactorForTImuDriverbody> = TImuDriverbodyDagReactor {
	c_dag_reactor: &EREACTORFORIMUDRIVERBODY,
};

