use crate::{t_alice::*, s_hello::*};

impl SHello for EAliceForTAlice<'_>{

	fn Hello(&self) {
		let c_person = self.cell.get_cell_ref();

	}
}

