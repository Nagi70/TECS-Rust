use spin::Mutex;
use crate::{t_alice::*, s_hello::*};

impl SHello for EAlice1ForTAlice<'_>{

	fn hello(&'static self) {
		let (c_bob, c_bob2, id, var, _mg) = self.cell.get_cell_ref();

		println!("Hello from Alice{}, var.count: {}", id, var.count);
		var.count += 1;
		c_bob.hello2();
		c_bob2.hello2();
		println!("MutexGuardForTAlice dropped");
	}
}

impl SHello for EAlice2ForTAlice<'_>{

	fn hello(&'static self) {
		let (c_bob, c_bob2, id, var, _mg) = self.cell.get_cell_ref();

		println!("Hello from Alice{}, var.count: {}", id, var.count);
		c_bob.hello2();
		c_bob2.hello2();
		println!("MutexGuardForTAlice dropped");
	}
}

