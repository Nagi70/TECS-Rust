use crate::tecs_global::*;
use crate::tecs_celltype::t_twist_with_covariance_aged_object_queue::*;
use crate::tecs_signature::{s_twist_with_covariance_set::*, s_twist_with_covariance_get::*};
use awkernel_lib::sync::mutex::MCSNode;
impl STwistWithCovarianceSet for ESetForTTwistWithCovarianceAgedObjectQueue<'_>{

	fn push(&'static self, twist: &TwistWithCovarianceStamped)-> Result<(), ()>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		lg.var.queue.enqueue((twist.clone(), 0)).map_err(|_| ())
	}
}

impl STwistWithCovarianceGet for EGetForTTwistWithCovarianceAgedObjectQueue<'_>{

	fn pop(&'static self) -> Option<TwistWithCovarianceStamped>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		// C++のAgedObjectQueue::pop()に相当: 先頭を取り出して返す（再キューなし）
		lg.var.queue.dequeue().map(|(twist, _age)| twist)
	}
	fn pop_increment_age(&'static self) -> Option<TwistWithCovarianceStamped>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		// C++のAgedObjectQueue::pop_increment_age()に相当:
		// 先頭を取り出し、age+1 が max_age 未満なら末尾へ(ageをインクリメントして)再キュー。
		lg.var.queue.dequeue().map(|(twist, age)| {
			let new_age = age.saturating_add(1);
			if new_age < *lg.max_age {
				// 再キューするので、返却する値とは別に clone が必要
				lg.var.queue.enqueue((twist.clone(), new_age)).ok();
			}
			twist
		})
	}
}

