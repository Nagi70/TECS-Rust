use crate::{t_bob::*, s_hello::*};

impl SHello for EBobForTBob<'_>{

	fn Hello(&self) {
		let (c_person, bob_attr) = self.cell.get_cell_ref();

	}
}

