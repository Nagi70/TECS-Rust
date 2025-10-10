use crate::tecs_signature::s_array_test::*;
use crate::tecs_celltype::t_array_test::*;
pub struct TArrayTestDagPeriodicReactor<'a, T>
where
	T: SArrayTest,
{
	pub c_dag_periodic_reactor: &'a T,
}

pub struct LockGuardForTArrayTestDagPeriodicReactor<'a, T>
where
	T: SArrayTest,
{
	pub c_dag_periodic_reactor: &'a T,
}

pub static ARRAYTESTDAGPERIODICREACTOR: TArrayTestDagPeriodicReactor<EReactorForTArrayTest> = TArrayTestDagPeriodicReactor {
	c_dag_periodic_reactor: &EREACTORFORARRAYTEST,
};

