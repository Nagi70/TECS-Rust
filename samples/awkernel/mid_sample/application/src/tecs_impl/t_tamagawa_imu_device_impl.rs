use crate::tecs_signature::t_tamagawa_imu_device::*;
use crate::tecs_signature::s_imu_device::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SImuDevice for EImuDeviceForTTamagawaImuDevice<'_>{

	fn read(&'static self, msg: &Frame, imu_msg: &mut ImuMsg) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		if(msg->id == lg.can_id_gyro) {
			imu_msg.header.frame_id = heapless::String::from_str(lg.imu_frame_id).unwrap();
			imu_msg.header.stamp = awkernel_lib::time::Time::now();
			lg.var.counter = msg->data[1] + (msg->data[0] << 8);
			lg.var.angular_velocity_x_raw = msg->data[3] + (msg->data[2] << 8);
			lg.var.angular_velocity_y_raw = msg->data[5] + (msg->data[4] << 8);
			lg.var.angular_velocity_z_raw = msg->data[7] + (msg->data[6] << 8);
			imu_msg->angular_velocity.x = lg.var.angular_velocity_x_raw as f64 * (200.0 / (2.0f32.powf(15.0))) * core::f32::consts::PI / 180.0;
			imu_msg->angular_velocity.y = lg.var.angular_velocity_y_raw as f64 * (200.0 / (2.0f32.powf(15.0))) * core::f32::consts::PI / 180.0;
			imu_msg->angular_velocity.z = lg.var.angular_velocity_z_raw as f64 * (200.0 / (2.0f32.powf(15.0))) * core::f32::consts::PI / 180.0;
		}
		if(msg->id == lg.can_id_accel) {
			lg.var.acceleration_x_raw = msg->data[3] + (msg->data[2] << 8);
			lg.var.acceleration_y_raw = msg->data[5] + (msg->data[4] << 8);
			lg.var.acceleration_z_raw = msg->data[7] + (msg->data[6] << 8);
			imu_msg->linear_acceleration.x = lg.var.acceleration_x_raw as f64 * (100.0 / (2.0f32.powf(15.0)));
			imu_msg->linear_acceleration.y = lg.var.acceleration_y_raw as f64 * (100.0 / (2.0f32.powf(15.0)));
			imu_msg->linear_acceleration.z = lg.var.acceleration_z_raw as f64 * (100.0 / (2.0f32.powf(15.0)));

			imu_msg->orientation.x = 0.0;
			imu_msg->orientation.y = 0.0;
			imu_msg->orientation.z = 0.0;
			imu_msg->orientation.w = 1.0;
		}

	}
}

