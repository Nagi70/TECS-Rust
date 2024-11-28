use crate::tecs_ex_ctrl::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::{t_alice::*, s_hello2::*, s_hello::*};

impl SHello for EAlice1ForTAlice<'_>{

	fn hello(&'static self) {
		let (c_bob, c_bob2, id, var, _lg) = self.cell.get_cell_ref();

	}
}

impl SHello for EAlice2ForTAlice<'_>{

	fn hello(&'static self) {
		let (c_bob, c_bob2, id, var, _lg) = self.cell.get_cell_ref();

	}
}

