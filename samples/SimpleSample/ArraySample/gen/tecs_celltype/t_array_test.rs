use crate::tecs_signature::{s_array::*, s_int::*};

use crate::tecs_celltype::{t_array::*, t_dummy::*};

pub struct TArrayTest<'a, T, U>
where
	T: SArray,
	U: SArray,
{
	c_array1: &'a T,
	c_array2: &'a U,
}

pub struct EReactorForTArrayTest<'a>{
	pub cell: &'a TArrayTest<'a, EArrayForTArray<'a>, EArrayForTArray<'a>>,
}

pub struct LockGuardForTArrayTest<'a, T, U>
where
	T: SArray,
	U: SArray,
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

impl<'a, T: SArray, U: SArray> TArrayTest<'a, T, U> {
	#[inline]
	pub fn get_cell_ref(&'a self) -> LockGuardForTArrayTest<'_, T, U>	{
		LockGuardForTArrayTest {
			c_array1: self.c_array1,
			c_array2: self.c_array2,
		}
	}
}
