use spin::Mutex;
use crate::{t_deb::*, s_hello::*};

impl SHello for EDebForTDeb<'_>{

	fn hello(&'static self) {
		let (id, var, _mg) = self.cell.get_cell_ref();

		println!("Hello from Deb{}, var.count: {}", id, var.count);
		println!("MutexGuardForTDeb dropped");
	}
}

