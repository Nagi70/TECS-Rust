use crate::tecs_struct_def::*;
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

	}
}

