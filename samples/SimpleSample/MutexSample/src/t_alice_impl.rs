// use spin::Mutex;
use crate::{t_alice::*, s_hello::*};

impl SHello for EAlice1ForTAlice<'_>{

	fn hello(&self) {
		let (c_person, id, var, _mg) = self.cell.get_cell_ref();

		println!("Hello from Alice{}, var.count: {}", id, var.count);
		var.count += 1;
		c_person.hello();
		println!("MutexGuardForTAlice dropped");
	}
}

impl SHello for EAlice2ForTAlice<'_>{

	fn hello(&self) {
		let (c_person, id, var, _mg) = self.cell.get_cell_ref();

		println!("Hello from Alice{}, var.count: {}", id, var.count);
		c_person.hello();
		println!("MutexGuardForTAlice dropped");
	}
}

