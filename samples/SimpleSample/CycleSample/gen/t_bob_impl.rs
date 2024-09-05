use spin::Mutex;
use crate::{t_bob::*, s_hello::*};

impl SHello for EBob1ForTBob<'_>{

	fn hello_from_this(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();

	}
}

impl SHello for EBob2ForTBob<'_>{

	fn hello_from_this(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();

	}
}

impl SHello for EBob3ForTBob<'_>{

	fn hello_from_this(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();

	}
}

impl SHello for EBob4ForTBob<'_>{

	fn hello_from_this(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();

	}
}

