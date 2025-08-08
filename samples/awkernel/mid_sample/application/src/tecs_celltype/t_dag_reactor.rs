use crate::tecs_signature::s_reactorbody::*;
use crate::tecs_celltype::t_imu_driver::*;
pub struct TDagReactor<'a, T>
where
	T: SReactorbody,
{
	c_dag_reactorbody: &'a T,
}

pub struct LockGuardForTDagReactor<'a, T>
where
	T: SReactorbody,
{
	pub c_dag_reactorbody: &'a T,
}

static IMUDRIVERREACTOR: TDagReactor<EImuDriverForTImuDriver> = TDagReactor {
	c_dag_reactorbody: &EIMUDRIVERFORIMUDRIVER,
};

