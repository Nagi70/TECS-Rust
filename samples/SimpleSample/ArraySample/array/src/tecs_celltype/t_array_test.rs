use crate::tecs_global::*;
use crate::tecs_signature::{s_array::*, s_int::*};

use crate::tecs_celltype::{t_array::*, t_dummy::*};

pub struct TArrayTest<T, U>
where
	T: SArray + 'static,
	U: SArray + 'static,
{
	c_array1: &'static T,
	c_array2: &'static U,
}

pub struct EReactorForTArrayTest {
	pub cell: &'static TArrayTest<EArrayForTArray, EArrayForTArray>,
}

pub struct LockGuardForTArrayTest<'a, T, U>
where
	T: SArray + 'static,
	U: SArray + 'static,
{
	pub c_array1: &'a T,
	pub c_array2: &'a U,
}

static ARRAYTEST: TArrayTest<EArrayForTArray, EArrayForTArray> = TArrayTest {
	c_array1: &EARRAYFORARRAY1,
	c_array2: &EARRAYFORARRAY2,
};

pub static EREACTORFORARRAYTEST: EReactorForTArrayTest = EReactorForTArrayTest {
	cell: &ARRAYTEST,
};

impl<T: SArray, U: SArray> TArrayTest<T, U> {
	#[inline]
	pub fn get_cell_ref(&'static self) -> LockGuardForTArrayTest<T, U> {
		LockGuardForTArrayTest {
			c_array1: self.c_array1,
			c_array2: self.c_array2,
		}
	}
}
