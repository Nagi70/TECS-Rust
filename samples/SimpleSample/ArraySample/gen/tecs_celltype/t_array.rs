use crate::tecs_variable::*;
pub struct TArray<'a>{
	attr_array: *[i32],
	variable: &'a TECSVariable<TArrayVar>,
}

pub struct TArrayVar{
	pub var_array: *mut [i32],
}

pub struct EArrayForTArray<'a>{
	pub cell: &'a TArray<'a>,
}

pub struct LockGuardForTArray<'a>{
	pub attr_array: &'a [i32],
	pub var: TECSVarGuard<'a, TArrayVar>,
}

static ARRAY1: TArray = TArray {
	attr_array: unsafe{ &ARRAY1ATTRARRAY1 as * [i32] },
	variable: &ARRAY1VAR,
};

static ARRAY1VAR: TECSVariable<TArrayVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TArrayVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		var_array: unsafe{ &mut ARRAY1VARARRAY1 as *mut [i32] },
	}
));
pub static EARRAYFORARRAY1: EArrayForTArray = EArrayForTArray {
	cell: &ARRAY1,
};

static ARRAY2: TArray = TArray {
	attr_array: unsafe{ &ARRAY2ATTRARRAY1 as * [i32] },
	variable: &ARRAY2VAR,
};

static ARRAY2VAR: TECSVariable<TArrayVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TArrayVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		var_array: unsafe{ &mut ARRAY2VARARRAY1 as *mut [i32] },
	}
));
pub static EARRAYFORARRAY2: EArrayForTArray = EArrayForTArray {
	cell: &ARRAY2,
};

static ARRAY1ATTRARRAY1: [i32; 1] = [0];
static mut ARRAY1VARARRAY1: [i32; 1] = Default::default();

static ARRAY2ATTRARRAY1: [i32; 2] = [0, 0];
static mut ARRAY2VARARRAY1: [i32; 2] = Default::default();

impl<'a> TArray<'a> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut awkernel_lib::sync::mutex::MCSNode<TArrayVar>) -> LockGuardForTArray<'_>
	where
		'b: 'a,
	{
		LockGuardForTArray {
			attr_array: &self.attr_array,
			var: self.variable.lock(node),
		}
	}
}
