use spin::Mutex;
use crate::{t_carol::*, s_hello::*};

impl SHello for ECarolForTCarol<'_>{

	fn Hello(&self) {
		let (id, var) = self.cell.get_cell_ref();

	}
}

