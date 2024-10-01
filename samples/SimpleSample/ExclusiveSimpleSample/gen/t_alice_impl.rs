use spin::Mutex;
use crate::{t_alice::*, s_hello2::*, s_hello::*};

impl SHello for EAlice1ForTAlice<'_>{

	fn hello(&'static self) {
		let (c_bob, c_bob2, id, var, _mg) = self.cell.get_cell_ref();

	}
}

impl SHello for EAlice2ForTAlice<'_>{

	fn hello(&'static self) {
		let (c_bob, c_bob2, id, var, _mg) = self.cell.get_cell_ref();

	}
}

