use crate::tecs_signature::s_dummy_imu_correctorbody::*;
use crate::tecs_celltype::t_dummy_imu_correctorbody::*;
pub struct TDummyImuCorrector<'a, T>
where
	T: SDummyImuCorrectorbody,
{
	pub c_dummy_imu_correctorbody: &'a T,
}

pub struct EDummyImuCorrectorForTDummyImuCorrector<'a>{
	pub cell: &'a TDummyImuCorrector<'a, EDummyImuCorrectorbodyForTDummyImuCorrectorbody<'a>>,
}

pub struct LockGuardForTDummyImuCorrector<'a, T>
where
	T: SDummyImuCorrectorbody,
{
	pub c_dummy_imu_correctorbody: &'a T,
}

static DUMMYIMUCORRECTOR: TDummyImuCorrector<EDummyImuCorrectorbodyForTDummyImuCorrectorbody> = TDummyImuCorrector {
	c_dummy_imu_correctorbody: &EDUMMYIMUCORRECTORBODYFORDUMMYIMUCORRECTORBODY,
};

pub static EDUMMYIMUCORRECTORFORDUMMYIMUCORRECTOR: EDummyImuCorrectorForTDummyImuCorrector = EDummyImuCorrectorForTDummyImuCorrector {
	cell: &DUMMYIMUCORRECTOR,
};

impl<T: SDummyImuCorrectorbody> TDummyImuCorrector<'_, T> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TDummyImuCorrector>) -> LockGuardForTDummyImuCorrector<'_, T>
	where
		'b: 'a,
	{
		LockGuardForTDummyImuCorrector {
			c_dummy_imu_correctorbody: self.c_dummy_imu_correctorbody,
		}
	}
}
