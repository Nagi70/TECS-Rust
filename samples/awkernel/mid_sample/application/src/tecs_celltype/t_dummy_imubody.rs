use crate::tecs_signature::s_imu::*;
use crate::tecs_celltype::t_imu_driverbody::*;
pub struct TDummyImubody{
}

pub struct EDummyImubodyForTDummyImubody<'a>{
	pub cell: &'a TDummyImubody,
}

pub struct LockGuardForTDummyImubody<'a>{
}

static DUMMYIMUBODY: TDummyImubody = TDummyImubody {
};

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
		}
	}
}
