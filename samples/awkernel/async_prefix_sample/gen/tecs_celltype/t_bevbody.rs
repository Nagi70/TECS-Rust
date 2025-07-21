use crate::tecs_signature::s_bevbody::*;
use crate::tecs_celltype::t_bev::*;
pub struct TBevbody<'a, T>
where
	T: SBevbody,
{
	pub c_bev: &'a T,
}

pub struct EBevbodyForTBevbody<'a>{
	pub cell: &'a TBevbody<'a, EBevForTBev<'a>>,
}

pub struct LockGuardForTBevbody<'a, T>
where
	T: SBevbody,
{
	pub c_bev: &'a T,
}

static BEVBODY: TBevbody<EBevForTBev> = TBevbody {
	c_bev: &EBEVFORBEV,
};

pub static EBEVBODYFORBEVBODY: EBevbodyForTBevbody = EBevbodyForTBevbody {
	cell: &BEVBODY,
};

impl<T: SBevbody> TBevbody<'_, T> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TBevbody>) -> LockGuardForTBevbody<'_, T>
	where
		'b: 'a,
	{
		LockGuardForTBevbody {
			c_bev: self.c_bev,
		}
	}
}
