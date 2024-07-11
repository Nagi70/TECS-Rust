use crate::{t_taskbody::*, s_hello::*, s_taskbody::*};

impl STaskbody for ETaskbodyForTTaskbody<'_>{

	fn main(&self) {
		let c_person = self.cell.get_cell_ref();

	}
}

