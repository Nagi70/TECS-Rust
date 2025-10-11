use crate::tecs_signature::s_imu_corrector::*;
use crate::tecs_celltype::t_imu_corrector::*;
pub struct TImuCorrectorDagReactor<T>
where
	T: SImuCorrector + 'static,
{
	pub c_dag_reactor: &'static T,
}

pub struct LockGuardForTImuCorrectorDagReactor<'a, T>
where
	T: SImuCorrector + 'static,
{
	pub c_dag_reactor: &'a T,
}

pub static IMUCORRECTORDAGREACTOR: TImuCorrectorDagReactor<EReactorForTImuCorrector> = TImuCorrectorDagReactor {
	c_dag_reactor: &EREACTORFORIMUCORRECTOR,
};

