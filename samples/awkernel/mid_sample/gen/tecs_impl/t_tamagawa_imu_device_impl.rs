use crate::tecs_signature::t_tamagawa_imu_device::*;
use crate::tecs_signature::s_imu_device::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SImuDevice for EImuDeviceForTTamagawaImuDevice<'_>{

	fn open(&'static self) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn read(&'static self, p_data: &mut ImuData) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn close(&'static self) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

