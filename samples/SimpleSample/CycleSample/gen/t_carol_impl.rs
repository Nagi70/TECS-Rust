use spin::Mutex;
use crate::{t_carol::*, s_hello::*};

impl SHello for ECarol1ForTCarol<'_>{

	fn hello_from_this(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();

	}
}

impl SHello for ECarol2ForTCarol<'_>{

	fn hello_from_this(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();

	}
}

