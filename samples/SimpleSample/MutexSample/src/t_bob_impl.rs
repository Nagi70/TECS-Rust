use crate::{t_bob::*, s_hello::*};

impl SHello for EBobForTBob<'_>{

	fn hello(&self) {
		let (c_carol, id, var, _mg) = self.cell.get_cell_ref();

		println!("Hello from Bob{}, var.count: {}", id, var.count);
		c_carol.hello();
		println!("MutexGuardForTBob dropped");
	}
}

