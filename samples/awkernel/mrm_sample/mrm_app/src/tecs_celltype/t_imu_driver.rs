use crate::tecs_global::*;
use crate::tecs_signature::{s_imu_raw::*, s_imu_device::*};

use crate::tecs_celltype::{t_imu_corrector::*, t_tamagawa_imu_device::*};

pub struct TImuDriver<T>
where
	T: SImuDevice + 'static,
{
	c_dev: &'static T,
}

pub struct EReactorForTImuDriver {
	pub cell: &'static TImuDriver<EImuDeviceForTTamagawaImuDevice>,
}

pub struct EImuForTImuDriver {
	pub cell: &'static TImuDriver<EImuDeviceForTTamagawaImuDevice>,
}

pub struct LockGuardForTImuDriver<'a, T>
where
	T: SImuDevice + 'static,
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

impl<T: SImuDevice> TImuDriver<T> {
	#[inline]
	pub fn get_cell_ref(&'static self) -> LockGuardForTImuDriver<T> {
		LockGuardForTImuDriver {
			c_dev: self.c_dev,
		}
	}
}
