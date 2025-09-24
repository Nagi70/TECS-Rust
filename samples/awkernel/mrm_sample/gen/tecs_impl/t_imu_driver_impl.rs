use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_imu_driver::*;
use crate::tecs_signature::{s_imu_driver::*, s_imu_raw::*, s_imu::*, s_imu_device::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SImuDriver for EReactorForTImuDriver<'_>{

	fn main(&'static self, imu: &Frame, imu_raw: &mut ImuMsg) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl SImu for EImuForTImuDriver<'_>{

	fn send(&'static self, imu: &Frame) {
		let mut lg = self.cell.get_cell_ref();

	}
}

