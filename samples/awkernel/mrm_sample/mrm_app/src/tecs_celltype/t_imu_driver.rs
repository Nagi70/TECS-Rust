use crate::tecs_struct_def::*;
use crate::tecs_signature::{s_imu_raw::*, s_imu_device::*};

use crate::tecs_celltype::{t_imu_corrector::*, t_tamagawa_imu_device::*};

pub struct TImuDriver<'a, T>
where
	T: SImuDevice,
{
	c_dev: &'a T,
}

pub struct EReactorForTImuDriver<'a>{
	pub cell: &'a TImuDriver<'a, EImuDeviceForTTamagawaImuDevice<'a>>,
}

pub struct EImuForTImuDriver<'a>{
	pub cell: &'a TImuDriver<'a, EImuDeviceForTTamagawaImuDevice<'a>>,
}

pub struct LockGuardForTImuDriver<'a, T>
where
	T: SImuDevice,
{
	pub c_dev: &'a T,
}

static IMUDRIVER: TImuDriver<EImuDeviceForTTamagawaImuDevice> = TImuDriver {
	c_dev: &EIMUDEVICEFORTAMAGAWACAN,
};

pub static EREACTORFORIMUDRIVER: EReactorForTImuDriver = EReactorForTImuDriver {
	cell: &IMUDRIVER,
};

pub static EIMUFORIMUDRIVER: EImuForTImuDriver = EImuForTImuDriver {
	cell: &IMUDRIVER,
};

impl<'a, T: SImuDevice> TImuDriver<'a, T> {
	#[inline]
	pub fn get_cell_ref(&'a self) -> LockGuardForTImuDriver<'_, T>	{
		LockGuardForTImuDriver {
			c_dev: self.c_dev,
		}
	}
}
