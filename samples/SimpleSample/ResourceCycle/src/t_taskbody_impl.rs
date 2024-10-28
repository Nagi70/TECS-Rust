use crate::{t_taskbody::*, s_hello::*, s_taskbody::*};

impl STaskbody for ETaskbodyForTTaskbody<'_>{

	fn main(&'static self) {
		let (c_person1, c_person2) = self.cell.get_cell_ref();

		c_person1.hello();
		c_person2.hello();
	}
}

