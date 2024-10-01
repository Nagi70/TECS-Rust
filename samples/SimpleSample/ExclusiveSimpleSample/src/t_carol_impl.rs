use spin::Mutex;
use crate::{t_carol::*, s_hello3::*};

impl SHello3 for ECarolForTCarol<'_>{

	fn hello3(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();

		println!("Hello from Carol{}, var: {}", id, var.count);
		println!("MutexGuardForTCarol dropped");
	}
}

