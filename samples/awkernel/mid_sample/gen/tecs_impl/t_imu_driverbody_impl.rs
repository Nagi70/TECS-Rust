use crate::tecs_signature::t_imu_driverbody::*;
use crate::tecs_signature::{s_imu_driverbody::*, s_imu_raw::*, s_imu::*, s_imu_device::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SImuDriverbody for EImuDriverbodyForTImuDriverbody<'_>{

	fn main(&'static self, imu: &Frame, imu_raw: &mut ImuMsg) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

impl SImu for EImuForTImuDriverbody<'_>{

}

