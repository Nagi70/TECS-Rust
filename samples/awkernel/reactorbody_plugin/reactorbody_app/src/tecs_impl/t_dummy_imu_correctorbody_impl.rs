use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_dummy_imu_correctorbody::*;
use crate::tecs_signature::{s_imu_raw::*, s_dummy_imu_correctorbody::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SImuRaw for EImuRawForTDummyImuCorrectorbody<'_>{

	fn send(&'static self, imu_raw: &ImuMsg) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl SDummyImuCorrectorbody for EReactorForTDummyImuCorrectorbody<'_>{

	fn main(&'static self, imu_raw: &ImuMsg) {
		let mut lg = self.cell.get_cell_ref();

	}
}

