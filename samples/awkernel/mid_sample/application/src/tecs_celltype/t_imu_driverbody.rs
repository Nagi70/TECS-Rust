use crate::tecs_signature::{s_imu_raw::*, s_imu_device::*};

use crate::tecs_celltype::{t_dummy_imu_correctorbody::*, t_tamagawa_imu_device::*};

pub struct TImuDriverbody<'a, T>
where
	T: SImuDevice,
{
	c_dev: &'a T,
}

pub struct EImuDriverbodyForTImuDriverbody<'a>{
	pub cell: &'a TImuDriverbody<'a, EImuDeviceForTTamagawaImuDevice<'a>>,
}

pub struct EImuForTImuDriverbody<'a>{
	pub cell: &'a TImuDriverbody<'a, EImuDeviceForTTamagawaImuDevice<'a>>,
}

pub struct LockGuardForTImuDriverbody<'a, T>
where
	T: SImuDevice,
{
	pub c_dev: &'a T,
}

static IMUDRIVERBODY: TImuDriverbody<EImuDeviceForTTamagawaImuDevice> = TImuDriverbody {
	c_dev: &EIMUDEVICEFORCAN,
};

pub static EIMUDRIVERBODYFORIMUDRIVERBODY: EImuDriverbodyForTImuDriverbody = EImuDriverbodyForTImuDriverbody {
	cell: &IMUDRIVERBODY,
};

pub static EIMUFORIMUDRIVERBODY: EImuForTImuDriverbody = EImuForTImuDriverbody {
	cell: &IMUDRIVERBODY,
};

impl<T: SImuDevice> TImuDriverbody<'_, T> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TImuDriverbody>) -> LockGuardForTImuDriverbody<'_, T>
	where
		'b: 'a,
	{
		LockGuardForTImuDriverbody {
			c_dev: self.c_dev,
		}
	}
}
