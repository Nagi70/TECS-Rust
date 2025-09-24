use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_imu_corrector::*;
use crate::tecs_signature::{s_imu_data::*, s_imu_raw::*, s_imu_corrector::*, s_tf::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SImuRaw for EImuRawForTImuCorrector<'_>{

	fn send(&'static self, imu_raw: &ImuMsg) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

impl SImuCorrector for EReactorForTImuCorrector<'_>{

	fn main(&'static self, imu_raw: &ImuMsg, imu_data: &mut ImuMsg) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

