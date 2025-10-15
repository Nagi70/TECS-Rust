use crate::tecs_global::*;
use crate::tecs_celltype::t_imu_corrector::*;
use crate::tecs_signature::{s_imu_data::*, s_imu_raw::*, s_imu_corrector::*, s_tf::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SImuRaw for EImuRawForTImuCorrector{

	fn send(&'static self, imu_raw: &ImuMsg) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

impl SImuCorrector for EReactorForTImuCorrector{

	fn main(&'static self, imu_raw: &ImuMsg, imu_data: &mut ImuMsg) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		// Apply angular velocity offsets
		imu_data.angular_velocity.x = imu_raw.angular_velocity.x - lg.angular_velocity_offset_x;
		imu_data.angular_velocity.y = imu_raw.angular_velocity.y - lg.angular_velocity_offset_y;
		imu_data.angular_velocity.z = imu_raw.angular_velocity.z - lg.angular_velocity_offset_z;

	    // Set covariances
		imu_data.angular_velocity_covariance[0] = libm::pow(*lg.angular_velocity_stddev_xx, 2.0);
		imu_data.angular_velocity_covariance[4] = libm::pow(*lg.angular_velocity_stddev_yy, 	2.0);
		imu_data.angular_velocity_covariance[8] = libm::pow(*lg.angular_velocity_stddev_zz, 2.0);

		imu_data.linear_acceleration_covariance[0] = libm::pow(*lg.accel_stddev, 2.0);
		imu_data.linear_acceleration_covariance[4] = libm::pow(*lg.accel_stddev, 2.0);
		imu_data.linear_acceleration_covariance[8] = libm::pow(*lg.accel_stddev, 2.0);

		imu_data.header.time_stamp = imu_raw.header.time_stamp;
		imu_data.header.frame_id = heapless::String::try_from(*lg.output_frame).unwrap();
		imu_data.linear_acceleration = lg.c_tf.transform_vector3(&imu_raw.linear_acceleration);
		imu_data.linear_acceleration_covariance = lg.c_tf.transform_covariance(&imu_raw.linear_acceleration_covariance);
		imu_data.angular_velocity = lg.c_tf.transform_vector3(&imu_data.angular_velocity);
		imu_data.angular_velocity_covariance = lg.c_tf.transform_covariance(&imu_raw.angular_velocity_covariance);
	}
}

