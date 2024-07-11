use spin::Mutex;
use crate::{t_bob::*, s_hello::*};

impl SHello for EBobForTBob<'_>{

	fn Hello(&self) {
		let (c_carol, id, var) = self.cell.get_cell_ref();

	}
}

