use spin::Mutex;
use crate::{t_bob::*, s_hello::*};

impl SHello for EBobForTBob<'_>{

	fn hello(&'static self) {
		let (c_alice, id, var, _mg) = self.cell.get_cell_ref();

	}
}

