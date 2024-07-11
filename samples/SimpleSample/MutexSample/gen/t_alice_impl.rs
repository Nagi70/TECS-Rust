use spin::Mutex;
use crate::{t_alice::*, s_hello::*};

impl SHello for EAlice1ForTAlice<'_>{

	fn Hello(&self) {
		let (c_carol, id, var) = self.cell.get_cell_ref();

	}
}

impl SHello for EAlice2ForTAlice<'_>{

	fn Hello(&self) {
		let (c_carol, id, var) = self.cell.get_cell_ref();

	}
}

