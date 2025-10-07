use crate::tecs_global::*;
use crate::tecs_celltype::t_vehicle_velocity_converter::*;
use crate::tecs_signature::{s_twist_with_covariance_stamped::*, s_velocity_status::*, s_vehicle_velocity_converter::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SVelocityStatus for EVelocityStatusForTVehicleVelocityConverter<'_>{

	fn send(&'static self, velocity_status: &VelocityReport) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl SVehicleVelocityConverter for EReactorForTVehicleVelocityConverter<'_>{

	fn main(&'static self, velocity_status: &VelocityReport, twist_with_covariance: &mut TwistWithCovarianceStamped) {
		let mut lg = self.cell.get_cell_ref();

		if velocity_status.header.frame_id != *lg.frame_id {
			// Frame ID does not match, do nothing
			log::warn!("frame_id is not base_link");
		}

		twist_with_covariance.header = velocity_status.header.clone();
		twist_with_covariance.twist.twist.linear.x = velocity_status.longitudinal_velocity * lg.speed_scale_factor;
		twist_with_covariance.twist.twist.linear.y = velocity_status.lateral_velocity;
		twist_with_covariance.twist.twist.angular.z = velocity_status.heading_rate;
		twist_with_covariance.twist.covariance[0] = lg.velocity_stddev_xx * lg.velocity_stddev_xx;
		twist_with_covariance.twist.covariance[7] = 10000.0;
		twist_with_covariance.twist.covariance[14] = 10000.0;
		twist_with_covariance.twist.covariance[21] = 10000.0;
		twist_with_covariance.twist.covariance[28] = 10000.0;
		twist_with_covariance.twist.covariance[35] = lg.angular_velocity_stddev_zz * lg.angular_velocity_stddev_zz;
	}
}

