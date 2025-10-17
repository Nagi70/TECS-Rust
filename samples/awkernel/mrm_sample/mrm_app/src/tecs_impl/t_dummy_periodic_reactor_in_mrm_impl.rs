use crate::tecs_global::*;
use crate::tecs_celltype::t_dummy_periodic_reactor_in_mrm::*;
use crate::tecs_signature::{s_imu::*, s_velocity_status::*, s_dummy_periodic_reactor_in_mrm::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SDummyPeriodicReactorInMrm for EReactorForTDummyPeriodicReactorInMrm{

	fn main(&self, imu: &mut Frame, velocity_status: &mut VelocityReport) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		if lg.var.i == 1000 {
			log::info!("1000 times finished");
		}

		// awkernel_lib::console::print("dummy_imubody\r\n");

		if lg.var.i % 2 == 0 {
			imu.id = 0x319;
		} else {
			imu.id = 0x31A;
		}
		lg.var.i += 1;

		imu.data[0] = lg.var.i as u8;
		imu.data[1] = (lg.var.i << 1) as u8;
		imu.data[2] = (lg.var.i << 2) as u8;
		imu.data[3] = (lg.var.i << 3) as u8;
		imu.data[4] = (lg.var.i << 4) as u8;
		imu.data[5] = (lg.var.i << 5) as u8;
		imu.data[6] = (lg.var.i << 6) as u8;
		imu.data[7] = (lg.var.i << 7) as u8;

		imu.header.time_stamp = awkernel_lib::time::Time::now();

		velocity_status.header.frame_id.clear();
		let _ = velocity_status.header.frame_id.push_str("base_link");
		velocity_status.longitudinal_velocity = lg.var.j;
		velocity_status.lateral_velocity = lg.var.j * 2.0;
		velocity_status.heading_rate = lg.var.j * 3.0;

		lg.var.j += 0.1;

		velocity_status.header.time_stamp = awkernel_lib::time::Time::now();
	}
}

