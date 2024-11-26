use itron::mutex::MutexRef;
use crate::tecs_mutex::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{t_carol::*, s_hello3::*};

impl SHello3 for ECarolForTCarol<'_>{

	fn hello3(&'static self) {
		let (id, var, _lg) = self.cell.get_cell_ref();

	}
}

