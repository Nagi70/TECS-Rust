use crate::{t_carol::*, s_hello::*};

impl SHello for ECarolForTCarol<'_>{

	fn hello(&self) {
		let (id, var, _mg) = self.cell.get_cell_ref();

		println!("Hello from Carol{}, var: {}", id, var.count);
		println!("MutexGuardForTCarol dropped");
	}
}

