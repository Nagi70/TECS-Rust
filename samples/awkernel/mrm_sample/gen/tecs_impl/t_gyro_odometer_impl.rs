use crate::tecs_global::*;
use crate::tecs_celltype::t_gyro_odometer::*;
use crate::tecs_signature::{s_twist_with_covariance_stamped::*, s_imu_data::*, s_gyro_odometer::*, s_tf::*};
use awkernel_lib::sync::mutex::MCSNode;
impl STwistWithCovarianceStamped for ETwistWithCovarianceVForTGyroOdometer{

	fn send(&'static self, twist_with_covariance: &TwistWithCovarianceStamped) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

impl SImuData for EImuDataForTGyroOdometer{

	fn send(&'static self, imu_data: &ImuMsg) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

impl SGyroOdometer for EReactorForTGyroOdometer{

	fn main(&'static self, vehicle_twist: &TwistWithCovarianceStamped, imu: &ImuMsg, twist_with_covariance: &mut TwistWithCovarianceStamped) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

