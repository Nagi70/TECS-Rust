use crate::tecs_signature::s_dummy_imubody::*;
use crate::tecs_celltype::t_dummy_imubody::*;
pub struct TDummyImu<'a, T>
where
	T: SDummyImubody,
{
	pub c_dummy_imubody: &'a T,
}

pub struct EDummyImuForTDummyImu<'a>{
	pub cell: &'a TDummyImu<'a, EDummyImubodyForTDummyImubody<'a>>,
}

pub struct LockGuardForTDummyImu<'a, T>
where
	T: SDummyImubody,
{
	pub c_dummy_imubody: &'a T,
}

static DUMMYIMU: TDummyImu<EDummyImubodyForTDummyImubody> = TDummyImu {
	c_dummy_imubody: &EDUMMYIMUBODYFORDUMMYIMUBODY,
};

pub static EDUMMYIMUFORDUMMYIMU: EDummyImuForTDummyImu = EDummyImuForTDummyImu {
	cell: &DUMMYIMU,
};

impl<T: SDummyImubody> TDummyImu<'_, T> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TDummyImu>) -> LockGuardForTDummyImu<'_, T>
	where
		'b: 'a,
	{
		LockGuardForTDummyImu {
			c_dummy_imubody: self.c_dummy_imubody,
		}
	}
}
