use crate::tecs_variable::*;
pub struct TTwistWithCovarianceAgedObjectQueue{
	max_age: i32,
	variable: &'static TECSVariable<TTwistWithCovarianceAgedObjectQueueVar>,
}

pub struct TTwistWithCovarianceAgedObjectQueueVar {
	pub queue: heapless::spsc::Queue<(TwistWithCovarianceStamped, i32), 128>,
}

pub struct ESetForTTwistWithCovarianceAgedObjectQueue {
	pub cell: &'static TTwistWithCovarianceAgedObjectQueue,
}

pub struct EGetForTTwistWithCovarianceAgedObjectQueue {
	pub cell: &'static TTwistWithCovarianceAgedObjectQueue,
}

pub struct LockGuardForTTwistWithCovarianceAgedObjectQueue<'a>{
	pub max_age: &'a i32,
	pub var: TECSVarGuard<'a, TTwistWithCovarianceAgedObjectQueueVar>,
}

static TWISTWITHCOVARIANCEQUEUE: TTwistWithCovarianceAgedObjectQueue = TTwistWithCovarianceAgedObjectQueue {
	max_age: 10,
	variable: &TWISTWITHCOVARIANCEQUEUEVAR,
};

static TWISTWITHCOVARIANCEQUEUEVAR: TECSVariable<TTwistWithCovarianceAgedObjectQueueVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TTwistWithCovarianceAgedObjectQueueVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
	queue: heapless::spsc::Queue::new(),
	}
));
pub static ESETFORTWISTWITHCOVARIANCEQUEUE: ESetForTTwistWithCovarianceAgedObjectQueue = ESetForTTwistWithCovarianceAgedObjectQueue {
	cell: &TWISTWITHCOVARIANCEQUEUE,
};

pub static EGETFORTWISTWITHCOVARIANCEQUEUE: EGetForTTwistWithCovarianceAgedObjectQueue = EGetForTTwistWithCovarianceAgedObjectQueue {
	cell: &TWISTWITHCOVARIANCEQUEUE,
};

impl TTwistWithCovarianceAgedObjectQueue {
	#[inline]
	pub fn get_cell_ref<'node>(&'static self, node: &'node mut awkernel_lib::sync::mutex::MCSNode<TTwistWithCovarianceAgedObjectQueueVar>) -> LockGuardForTTwistWithCovarianceAgedObjectQueue<'node> {
		LockGuardForTTwistWithCovarianceAgedObjectQueue {
			max_age: &self.max_age,
			var: self.variable.lock(node),
		}
	}
}
