use crate::tecs_variable::*;
use crate::tecs_struct_def::*;
use crate::tecs_signature::s_imu::*;
use crate::tecs_celltype::t_imu_driverbody::*;
pub struct TDummyImubody<'a>{
	variable: &'a TECSVariable<TDummyImubodyVar>,
}

pub struct TDummyImubodyVar{
	pub i: i32,
}

pub struct EReactorForTDummyImubody<'a>{
	pub cell: &'a TDummyImubody<'a>,
}

pub struct LockGuardForTDummyImubody<'a>{
	pub var: TECSVarGuard<'a, TDummyImubodyVar>,
}

static DUMMYIMUBODY: TDummyImubody = TDummyImubody {
	variable: &DUMMYIMUBODYVAR,
};

static DUMMYIMUBODYVAR: TECSVariable<TDummyImubodyVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TDummyImubodyVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		i: 0,
	}
));
pub static EREACTORFORDUMMYIMUBODY: EReactorForTDummyImubody = EReactorForTDummyImubody {
	cell: &DUMMYIMUBODY,
};

impl<'a> TDummyImubody<'a> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut awkernel_lib::sync::mutex::MCSNode<TDummyImubodyVar>) -> LockGuardForTDummyImubody<'_>
	where
		'b: 'a,
	{
		LockGuardForTDummyImubody {
			var: self.variable.lock(node),
		}
	}
}
