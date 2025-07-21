use crate::tecs_variable::*;
use crate::tecs_signature::s_camera_info::*;
use crate::tecs_celltype::t_bev::*;
pub struct TCamera{
	variable: &'a TECSVariable<TCamera>,
}

pub struct TCameraVar{
	pub temp: u32,
}

pub struct ECameraForTCamera<'a>{
	pub cell: &'a TCamera,
}

pub struct LockGuardForTCamera<'a>{
	pub var: TECSVarGuard<'a, TCamera>,
}

static CAMERA: TCamera = TCamera {
	variable: &CAMERAVAR,
};

static CAMERAVAR: TECSVariable<TCamera> = TECSVariable::Raw(TECSSyncVar { unsafe_var: UnsafeCell::new(
	TCamera {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		temp: 0,
	}),
});

pub static ECAMERAFORCAMERA: ECameraForTCamera = ECameraForTCamera {
	cell: &CAMERA,
};

impl TCamera {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TCamera>) -> LockGuardForTCamera
	where
		'b: 'a,
	{
		LockGuardForTCamera {
			var: self.variable.lock(node),
		}
	}
}
