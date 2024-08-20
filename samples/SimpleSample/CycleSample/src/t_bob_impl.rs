use spin::Mutex;
use crate::{t_bob::*, s_hello::*};

impl SHello for EBob1ForTBob<'_>{

	fn hello(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();
		println!("Hello from Bob{}, var.count: {}", id, var.count);
		println!("MutexGuardForTBob dropped");
	}
}

impl SHello for EBob2ForTBob<'_>{

	fn hello(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();
		println!("Hello from Bob{}, var.count: {}", id, var.count);
		println!("MutexGuardForTBob dropped");
	}
}

impl SHello for EBob3ForTBob<'_>{

	fn hello(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();
		println!("Hello from Bob{}, var.count: {}", id, var.count);
		println!("MutexGuardForTBob dropped");
	}
}

impl SHello for EBob4ForTBob<'_>{

	fn hello(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();
		println!("Hello from Bob{}, var.count: {}", id, var.count);
		println!("MutexGuardForTBob dropped");
	}
}

