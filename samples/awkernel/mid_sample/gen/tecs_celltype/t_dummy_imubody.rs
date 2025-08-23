use crate::tecs_variable::*;
use crate::tecs_signature::s_imu::*;
use crate::tecs_celltype::t_imu_driverbody::*;
pub struct TDummyImubody{
	variable: &'a TECSVariable<TDummyImubody>,
}

pub struct TDummyImubodyVar{
	pub i: i32,
}

pub struct EDummyImubodyForTDummyImubody<'a>{
	pub cell: &'a TDummyImubody,
}

pub struct LockGuardForTDummyImubody<'a>{
	pub var: TECSVarGuard<'a, TDummyImubody>,
}

static DUMMYIMUBODY: TDummyImubody = TDummyImubody {
	variable: &DUMMYIMUBODYVAR,
};

static DUMMYIMUBODYVAR: TECSVariable<TDummyImubody> = TECSVariable::Raw(TECSSyncVar { unsafe_var: UnsafeCell::new(
	TDummyImubody {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		i: 0,
	}),
});

pub static EDUMMYIMUBODYFORDUMMYIMUBODY: EDummyImubodyForTDummyImubody = EDummyImubodyForTDummyImubody {
	cell: &DUMMYIMUBODY,
};

impl TDummyImubody {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TDummyImubody>) -> LockGuardForTDummyImubody
	where
		'b: 'a,
	{
		LockGuardForTDummyImubody {
			var: self.variable.lock(node),
		}
	}
}
