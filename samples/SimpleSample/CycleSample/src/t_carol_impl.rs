use spin::Mutex;
use crate::{t_carol::*, s_hello::*};

impl SHello for ECarol1ForTCarol<'_>{

	fn hello(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();
		println!("Hello from Carol{}, var: {}", id, var.count);
		println!("MutexGuardForTCarol dropped");
	}
}

impl SHello for ECarol2ForTCarol<'_>{

	fn hello(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();
		println!("Hello from Carol{}, var: {}", id, var.count);
		println!("MutexGuardForTCarol dropped");
	}
}

