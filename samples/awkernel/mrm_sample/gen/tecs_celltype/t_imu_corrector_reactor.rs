use crate::tecs_signature::s_imu_corrector::*;
use crate::tecs_celltype::t_imu_corrector::*;
pub struct TImuCorrectorReactor<'a, T>
where
	T: SImuCorrector,
{
	pub c_reactor: &'a T,
}

pub struct LockGuardForTImuCorrectorReactor<'a, T>
where
	T: SImuCorrector,
{
	pub c_reactor: &'a T,
}

pub static IMUCORRECTORREACTOR: TImuCorrectorReactor<EReactorForTImuCorrector> = TImuCorrectorReactor {
	c_reactor: &EREACTORFORIMUCORRECTOR,
};

