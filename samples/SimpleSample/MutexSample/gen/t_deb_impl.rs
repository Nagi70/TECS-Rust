use spin::Mutex;
use crate::{t_deb::*, s_hello::*};

impl SHello for EDebForTDeb<'_>{

	fn hello(&self) {
		let (id, var) = self.cell.get_cell_ref();

	}
}

