use crate::tecs_signature::s_imu_driver::*;
use crate::tecs_celltype::t_imu_driver::*;
pub struct TImuDriverDagReactor<T>
where
	T: SImuDriver + 'static,
{
	pub c_dag_reactor: &'static T,
}

pub struct LockGuardForTImuDriverDagReactor<'a, T>
where
	T: SImuDriver + 'static,
{
	pub c_dag_reactor: &'a T,
}

pub static IMUDRIVERDAGREACTOR: TImuDriverDagReactor<EReactorForTImuDriver> = TImuDriverDagReactor {
	c_dag_reactor: &EREACTORFORIMUDRIVER,
};

