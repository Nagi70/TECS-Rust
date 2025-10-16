use crate::tecs_variable::*;
use crate::tecs_global::*;
pub struct TArray{
	attr_array: &'static [i32],
	variable: &'static TECSVariable<TArrayVar>,
}

pub struct TArrayVar {
	pub var_array: &'static mut [i32],
}

pub struct EArrayForTArray {
	pub cell: &'static TArray,
}

pub struct LockGuardForTArray<'a>{
	pub attr_array: &'a [i32],
	pub var: TECSVarGuard<'a, TArrayVar>,
}

static ARRAY1: TArray = TArray {
	attr_array: &ARRAY1ATTRARRAY1,
	variable: &ARRAY1VAR,
};

static ARRAY1VAR: TECSVariable<TArrayVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TArrayVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		var_array: unsafe{ &mut *core::ptr::addr_of_mut!(ARRAY1VARARRAY1) },
	}
));
pub static EARRAYFORARRAY1: EArrayForTArray = EArrayForTArray {
	cell: &ARRAY1,
};

static ARRAY2: TArray = TArray {
	attr_array: &ARRAY2ATTRARRAY1,
	variable: &ARRAY2VAR,
};

static ARRAY2VAR: TECSVariable<TArrayVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TArrayVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		var_array: unsafe{ &mut *core::ptr::addr_of_mut!(ARRAY2VARARRAY1) },
	}
));
pub static EARRAYFORARRAY2: EArrayForTArray = EArrayForTArray {
	cell: &ARRAY2,
};

static ARRAY1ATTRARRAY1: [i32; 1] = [0; 1];

static mut ARRAY1VARARRAY1: [i32; 1] = [0; 1];

static ARRAY2ATTRARRAY1: [i32; 2] = [0; 2];

static mut ARRAY2VARARRAY1: [i32; 2] = [0; 2];

impl TArray {
	#[inline]
	pub fn get_cell_ref<'node>(&'static self, node: &'node mut awkernel_lib::sync::mutex::MCSNode<TArrayVar>) -> LockGuardForTArray<'node> {
		LockGuardForTArray {
			attr_array: &self.attr_array,
			var: self.variable.lock(node),
		}
	}
}
