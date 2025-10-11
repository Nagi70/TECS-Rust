use crate::tecs_global::*;
use crate::tecs_celltype::t_dummy_periodic_reactor_in_mrm::*;
use crate::tecs_signature::{s_imu::*, s_velocity_status::*, s_dummy_periodic_reactor_in_mrm::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SDummyPeriodicReactorInMrm for EReactorForTDummyPeriodicReactorInMrm{

	fn main(&'static self, imu: &mut Frame, velocity_status: &mut VelocityReport) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

