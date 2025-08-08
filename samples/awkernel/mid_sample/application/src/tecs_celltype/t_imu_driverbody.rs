use crate::tecs_signature::{s_imu_raw::*, s_imu_device::*, s_rate_monitor::*};

use crate::tecs_celltype::{t_dummy_imu_correctorbody::*, t_tamagawa_imu_device::*, t_rate_bound_status::*};

pub struct TImuDriverbody<'a, T, U>
where
	T: SImuDevice,
	U: SRateMonitor,
{
	c_dev: &'a T,
	c_rate: &'a U,
}

pub struct EImuDriverbodyForTImuDriverbody<'a>{
	pub cell: &'a TImuDriverbody<'a, EImuDeviceForTTamagawaImuDevice<'a>, ERateForTRateBoundStatus<'a>>,
}

pub struct EImuForTImuDriverbody<'a>{
	pub cell: &'a TImuDriverbody<'a, EImuDeviceForTTamagawaImuDevice<'a>, ERateForTRateBoundStatus<'a>>,
}

pub struct LockGuardForTImuDriverbody<'a, T, U>
where
	T: SImuDevice,
	U: SRateMonitor,
{
	pub c_dev: &'a T,
	pub c_rate: &'a U,
}

static IMUDRIVERBODY: TImuDriverbody<EImuDeviceForTTamagawaImuDevice, ERateForTRateBoundStatus> = TImuDriverbody {
	c_dev: &EIMUDEVICEFORCAN,
	c_rate: &ERATEFORIMUDRIVERDIAG,
};

pub static EIMUDRIVERBODYFORIMUDRIVERBODY: EImuDriverbodyForTImuDriverbody = EImuDriverbodyForTImuDriverbody {
	cell: &IMUDRIVERBODY,
};

pub static EIMUFORIMUDRIVERBODY: EImuForTImuDriverbody = EImuForTImuDriverbody {
	cell: &IMUDRIVERBODY,
};

impl<T: SImuDevice, U: SRateMonitor> TImuDriverbody<'_, T, U> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TImuDriverbody>) -> LockGuardForTImuDriverbody<'_, T, U>
	where
		'b: 'a,
	{
		LockGuardForTImuDriverbody {
			c_dev: self.c_dev,
			c_rate: self.c_rate,
		}
	}
}
