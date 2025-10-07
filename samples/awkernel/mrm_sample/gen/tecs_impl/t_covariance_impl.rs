use crate::tecs_global::*;
use crate::tecs_celltype::t_covariance::*;
use crate::tecs_signature::s_covariance::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SCovariance for ECovForTCovariance<'_>{

	fn ekf_covariance_to_pose_message_covariance(&'static self, p: &nalgebra::Matrix6<f64>) -> nalgebra::Matrix6<f64>{

	}
	fn ekf_covariance_to_twist_message_covariance(&'static self, p: &nalgebra::Matrix6<f64>) -> nalgebra::Matrix6<f64>{

	}
}

