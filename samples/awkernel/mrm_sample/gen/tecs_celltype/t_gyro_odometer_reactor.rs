use crate::tecs_signature::s_gyro_odometer::*;
use crate::tecs_celltype::t_gyro_odometer::*;
pub struct TGyroOdometerReactor<'a, T>
where
	T: SGyroOdometer,
{
	pub c_reactor: &'a T,
}

pub struct LockGuardForTGyroOdometerReactor<'a, T>
where
	T: SGyroOdometer,
{
	pub c_reactor: &'a T,
}

pub static GYROODOMETERREACTOR: TGyroOdometerReactor<EReactorForTGyroOdometer> = TGyroOdometerReactor {
	c_reactor: &EREACTORFORGYROODOMETER,
};

