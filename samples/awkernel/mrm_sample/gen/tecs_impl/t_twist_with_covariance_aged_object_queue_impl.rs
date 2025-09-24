use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_twist_with_covariance_aged_object_queue::*;
use crate::tecs_signature::{s_twist_with_covariance_set::*, s_twist_with_covariance_get::*};
use awkernel_lib::sync::mutex::MCSNode;
impl STwistWithCovarianceSet for ESetForTTwistWithCovarianceAgedObjectQueue<'_>{

	fn push(&'static self, twist: &TwistWithCovarianceStamped) -> Result<TwistWithCovarianceStamped>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

impl STwistWithCovarianceGet for EGetForTTwistWithCovarianceAgedObjectQueue<'_>{

	fn pop(&'static self) -> Result<TwistWithCovarianceStamped>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
	fn pop_increment_age(&'static self) -> Result<TwistWithCovarianceStamped>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

