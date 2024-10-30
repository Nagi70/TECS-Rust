use spin::Mutex;
use crate::{t_manager::*, s_task_body::*, s_manage::*, s_motor::*};

impl STaskBody for EManage1ForTManager<'_>{

	fn main(&'static self) {
		let (c_motor, var, _lg) = self.cell.get_cell_ref();

	}
}

impl SManage for EManage2ForTManager<'_>{

	fn manage(&'static self) {
		let (c_motor, var, _lg) = self.cell.get_cell_ref();

	}
}

