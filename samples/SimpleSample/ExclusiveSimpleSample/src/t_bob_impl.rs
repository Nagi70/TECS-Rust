use spin::Mutex;
use crate::{t_bob::*, s_hello3::*, s_hello2::*, s_hello::*};

impl SHello2 for EBob1ForTBob<'_>{

	fn hello2(&'static self) {
		let (c_carol, id, var, _mg) = self.cell.get_cell_ref();

		println!("Hello from Bob{}, var.count: {}", id, var.count);
		c_carol.hello3();
		println!("MutexGuardForTBob dropped");
	}
}

impl SHello for EBob2ForTBob<'_>{

	fn hello(&'static self) {
		let (c_carol, id, var, _mg) = self.cell.get_cell_ref();

		println!("Hello from Bob{}, var.count: {}", id, var.count);
		c_carol.hello3();
		println!("MutexGuardForTBob dropped");
	}
}

