use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_gyro_odometer::*;
use crate::tecs_signature::{s_twist_with_covariance_stamped::*, s_imu_data::*, s_gyro_odometer::*, s_tf::*};
use awkernel_lib::sync::mutex::MCSNode;
impl STwistWithCovarianceStamped for ETwistWithCovarianceVForTGyroOdometer<'_>{

	fn send(&'static self, twist_with_covariance: &TwistWithCovarianceStamped) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl SImuData for EImuDataForTGyroOdometer<'_>{

	fn send(&'static self, imu_data: &ImuMsg) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl SGyroOdometer for EReactorForTGyroOdometer<'_>{

	fn main(&'static self, vehicle_twist: &TwistWithCovarianceStamped, imu: &ImuMsg, twist_with_covariance: &mut TwistWithCovarianceStamped) {
		let mut lg = self.cell.get_cell_ref();

		lg.var.imu_covariance = lg.c_tf.transform_covariance(imu.angular_velocity_covariance);

		if vehicle_twist.header.stamp > imu.header.stamp {
			twist_with_covariance.header.stamp = vehicle_twist.header.stamp;
		} else {
			twist_with_covariance.header.stamp = imu.header.stamp;
		}

		twist_with_covariance.header.frame_id = heapless::String::try_from(*lg.output_frame).unwrap();
		twist_with_covariance.twist.twist.linear.x = vehicle_twist.twist.linear.x;
		twist_with_covariance.twist.twist.angular = lg.c_tf.transform_vector3(imu.angular_velocity);

		twist_with_covariance.twist.covariance[0] = vehicle_twist.twist.covariance[0];
		twist_with_covariance.twist.covariance[7] = 10000.0;
		twist_with_covariance.twist.covariance[14] = 10000.0;
		twist_with_covariance.twist.covariance[21] = lg.var.imu_covariance[0];
		twist_with_covariance.twist.covariance[28] = lg.var.imu_covariance[4];
		twist_with_covariance.twist.covariance[35] = lg.var.imu_covariance[8];

		if twist_with_covariance.twist.twist.angular.z.abs() < 0.01 && twist_with_covariance.twist.twist.linear.x.abs() < 0.01
		{
			twist_with_covariance.twist.twist.angular.x = 0.0;
			twist_with_covariance.twist.twist.angular.y = 0.0;
			twist_with_covariance.twist.twist.angular.z = 0.0;
		}
	}
}

