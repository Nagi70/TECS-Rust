use spin::Mutex;
use crate::{t_bob::*, s_hello::*};

impl SHello for EBob1ForTBob<'_>{

	fn hello(&'static self) {
		let (c_carol, id, var, _mg) = self.cell.get_cell_ref();

	}
}

impl SHello for EBob2ForTBob<'_>{

	fn hello(&'static self) {
		let (c_carol, id, var, _mg) = self.cell.get_cell_ref();

	}
}

