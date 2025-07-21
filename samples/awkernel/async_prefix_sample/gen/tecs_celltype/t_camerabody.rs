use crate::tecs_signature::s_camerabody::*;
use crate::tecs_celltype::t_camera::*;
pub struct TCamerabody<'a, T>
where
	T: SCamerabody,
{
	pub c_camera: &'a T,
}

pub struct ECamerabodyForTCamerabody<'a>{
	pub cell: &'a TCamerabody<'a, ECameraForTCamera<'a>>,
}

pub struct LockGuardForTCamerabody<'a, T>
where
	T: SCamerabody,
{
	pub c_camera: &'a T,
}

static CAMERABODY: TCamerabody<ECameraForTCamera> = TCamerabody {
	c_camera: &ECAMERAFORCAMERA,
};

pub static ECAMERABODYFORCAMERABODY: ECamerabodyForTCamerabody = ECamerabodyForTCamerabody {
	cell: &CAMERABODY,
};

impl<T: SCamerabody> TCamerabody<'_, T> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TCamerabody>) -> LockGuardForTCamerabody<'_, T>
	where
		'b: 'a,
	{
		LockGuardForTCamerabody {
			c_camera: self.c_camera,
		}
	}
}
