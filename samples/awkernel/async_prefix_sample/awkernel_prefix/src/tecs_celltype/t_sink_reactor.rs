use crate::tecs_signature::s_reactorbody::*;
use crate::tecs_celltype::t_bevbody::*;
pub struct TSinkReactor<'a, T>
where
	T: SReactorbody,
{
	c_sink_reactorbody: &'a T,
}

pub struct ETaskForTSinkReactor<'a>{
	pub cell: &'a TSinkReactor<'a, EBevbodyForTBevbody<'a>>,
}

pub struct LockGuardForTSinkReactor<'a, T>
where
	T: SReactorbody,
{
	pub c_sink_reactorbody: &'a T,
}

static SINKREACTOR: TSinkReactor<EBevbodyForTBevbody> = TSinkReactor {
	c_sink_reactorbody: &EBEVBODYFORBEVBODY,
};

pub static ETASKFORSINKREACTOR: ETaskForTSinkReactor = ETaskForTSinkReactor {
	cell: &SINKREACTOR,
};

impl<T: SReactorbody> TSinkReactor<'_, T> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TSinkReactor>) -> LockGuardForTSinkReactor<'_, T>
	where
		'b: 'a,
	{
		LockGuardForTSinkReactor {
			c_sink_reactorbody: self.c_sink_reactorbody,
		}
	}
}
