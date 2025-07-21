use crate::tecs_signature::s_reactorbody::*;
use crate::tecs_celltype::t_bevbody::*;
pub struct TReactor<'a, T>
where
	T: SReactorbody,
{
	c_reactorbody: &'a T,
}

pub struct ETaskForTReactor<'a>{
	pub cell: &'a TReactor<'a, EBevbodyForTBevbody<'a>>,
}

pub struct LockGuardForTReactor<'a, T>
where
	T: SReactorbody,
{
	pub c_reactorbody: &'a T,
}

static REACTOR: TReactor<EBevbodyForTBevbody> = TReactor {
	c_reactorbody: &EBEVBODYFORBEVBODY,
};

pub static ETASKFORREACTOR: ETaskForTReactor = ETaskForTReactor {
	cell: &REACTOR,
};

impl<T: SReactorbody> TReactor<'_, T> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TReactor>) -> LockGuardForTReactor<'_, T>
	where
		'b: 'a,
	{
		LockGuardForTReactor {
			c_reactorbody: self.c_reactorbody,
		}
	}
}
