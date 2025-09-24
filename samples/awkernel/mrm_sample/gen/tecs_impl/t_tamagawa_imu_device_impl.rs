use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_tamagawa_imu_device::*;
use crate::tecs_signature::s_imu_device::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SImuDevice for EImuDeviceForTTamagawaImuDevice<'_>{

	fn read(&'static self, msg: &Frame, imu_msg: &mut ImuMsg) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

