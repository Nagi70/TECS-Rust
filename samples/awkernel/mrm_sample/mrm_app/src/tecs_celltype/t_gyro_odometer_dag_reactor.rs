use crate::tecs_signature::s_gyro_odometer::*;
use crate::tecs_celltype::t_gyro_odometer::*;
pub struct TGyroOdometerDagReactor<T>
where
	T: SGyroOdometer + 'static,
{
	pub c_dag_reactor: &'static T,
}

pub struct LockGuardForTGyroOdometerDagReactor<'a, T>
where
	T: SGyroOdometer + 'static,
{
	pub c_dag_reactor: &'a T,
}

pub static GYROODOMETERDAGREACTOR: TGyroOdometerDagReactor<EReactorForTGyroOdometer> = TGyroOdometerDagReactor {
	c_dag_reactor: &EREACTORFORGYROODOMETER,
};

