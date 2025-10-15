use crate::tecs_global::*;
use crate::tecs_celltype::t_tamagawa_imu_device::*;
use crate::tecs_signature::s_imu_device::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SImuDevice for EImuDeviceForTTamagawaImuDevice{

	fn read(&'static self, msg: &Frame, imu_msg: &mut ImuMsg) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);
		
		if msg.id == *lg.can_id_gyro {
			imu_msg.header.frame_id = heapless::String::try_from(*lg.imu_frame_id).unwrap();
			imu_msg.header.time_stamp = awkernel_lib::time::Time::now();
			lg.var.counter = msg.data[1] as u16 + ((msg.data[0] as u16) << 8);
			lg.var.angular_velocity_x_raw = msg.data[3] as i16 + ((msg.data[2] as i16) << 8);
			lg.var.angular_velocity_y_raw = msg.data[5] as i16 + ((msg.data[4] as i16) << 8);
			lg.var.angular_velocity_z_raw = msg.data[7] as i16 + ((msg.data[6] as i16) << 8);
			imu_msg.angular_velocity.x = (lg.var.angular_velocity_x_raw as f64) * ((200.0 / (2u32.pow(15)) as f64) * (core::f64::consts::PI / 180.0));
			imu_msg.angular_velocity.y = (lg.var.angular_velocity_y_raw as f64) * ((200.0 / (2u32.pow(15)) as f64) * (core::f64::consts::PI / 180.0));
			imu_msg.angular_velocity.z = (lg.var.angular_velocity_z_raw as f64) * ((200.0 / (2u32.pow(15)) as f64) * (core::f64::consts::PI / 180.0));
		}
		if msg.id == *lg.can_id_accel {
			lg.var.acceleration_x_raw = msg.data[3] as i16 + ((msg.data[2] as i16) << 8);
			lg.var.acceleration_y_raw = msg.data[5] as i16 + ((msg.data[4] as i16) << 8);
			lg.var.acceleration_z_raw = msg.data[7] as i16 + ((msg.data[6] as i16) << 8);
			imu_msg.linear_acceleration.x = (lg.var.acceleration_x_raw as f64) * (100.0 / (2u32.pow(15) as f64));
			imu_msg.linear_acceleration.y = (lg.var.acceleration_y_raw as f64) * (100.0 / (2u32.pow(15) as f64));
			imu_msg.linear_acceleration.z = (lg.var.acceleration_z_raw as f64) * (100.0 / (2u32.pow(15) as f64));

			imu_msg.orientation.i = 0.0;
			imu_msg.orientation.j = 0.0;
			imu_msg.orientation.k = 0.0;
			imu_msg.orientation.w = 1.0;
		}
	}
}

