use crate::tecs_global::*;
use crate::tecs_celltype::t_ekf_localizer::*;
use crate::tecs_signature::{s_twist_with_covariance_set::*, s_twist_with_covariance_stamped::*, s_ekf_localizer::*};
use awkernel_lib::sync::mutex::MCSNode;
impl STwistWithCovarianceStamped for ETwistWithCovarianceGForTEkfLocalizer{

	fn send(&'static self, twist_with_covariance: &TwistWithCovarianceStamped) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl SEkfLocalizer for EReactorForTEkfLocalizer{

	fn main(&'static self, twist: &TwistWithCovarianceStamped) {
		let mut lg = self.cell.get_cell_ref();

		if twist.twist.twist.linear.x.abs() < lg.threshold_linear_velocity_mps {
			twist.twist.covariance[0] = 10000.0;
		}

		lg.c_twist_with_covariance_queue.push(twist);
	}
}

