use crate::{t_carol::*, s_hello::*};

impl SHello for ECarolForTCarol<'_>{

	fn Hello(&self) {
		let (c_person, carol_attr) = self.cell.get_cell_ref();

	}
}

