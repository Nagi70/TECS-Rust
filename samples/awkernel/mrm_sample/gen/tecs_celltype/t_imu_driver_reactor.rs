use crate::tecs_signature::s_imu_driver::*;
use crate::tecs_celltype::t_imu_driver::*;
pub struct TImuDriverReactor<'a, T>
where
	T: SImuDriver,
{
	pub c_reactor: &'a T,
}

pub struct LockGuardForTImuDriverReactor<'a, T>
where
	T: SImuDriver,
{
	pub c_reactor: &'a T,
}

pub static IMUDRIVERREACTOR: TImuDriverReactor<EReactorForTImuDriver> = TImuDriverReactor {
	c_reactor: &EREACTORFORIMUDRIVER,
};

