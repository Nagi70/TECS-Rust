use spin::Mutex;
use crate::{t_bob::*, s_hello::*};

impl SHello for EBobForTBob<'_>{

	fn Hello(&'static self) {
		let (c_person, bob_attr, var, _mg) = self.cell.get_cell_ref();

	}
}

