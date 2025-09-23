use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_imu_driverbody::*;
use crate::tecs_signature::{s_imu_raw::*, s_imu::*, s_imudriverbody::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SImu for EImuForTImuDriverbody<'_>{

	fn send(&'static self, imu: &ImuMsg) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl SImudriverbody for EReactorForTImuDriverbody<'_>{

	fn main(&'static self, imu: &ImuMsg, imu_raw: &mut ImuMsg) {
		let mut lg = self.cell.get_cell_ref();

	}
}

