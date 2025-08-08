use crate::tecs_signature::s_imu_driverbody::*;
use crate::tecs_celltype::t_imu_driverbody::*;
pub struct TImuDriver<'a, T>
where
	T: SImuDriverbody,
{
	pub c_imu_driverbody: &'a T,
}

pub struct EImuDriverForTImuDriver<'a>{
	pub cell: &'a TImuDriver<'a, EImuDriverbodyForTImuDriverbody<'a>>,
}

pub struct LockGuardForTImuDriver<'a, T>
where
	T: SImuDriverbody,
{
	pub c_imu_driverbody: &'a T,
}

static IMUDRIVER: TImuDriver<EImuDriverbodyForTImuDriverbody> = TImuDriver {
	c_imu_driverbody: &EIMUDRIVERBODYFORIMUDRIVERBODY,
};

pub static EIMUDRIVERFORIMUDRIVER: EImuDriverForTImuDriver = EImuDriverForTImuDriver {
	cell: &IMUDRIVER,
};

impl<T: SImuDriverbody> TImuDriver<'_, T> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TImuDriver>) -> LockGuardForTImuDriver<'_, T>
	where
		'b: 'a,
	{
		LockGuardForTImuDriver {
			c_imu_driverbody: self.c_imu_driverbody,
		}
	}
}
