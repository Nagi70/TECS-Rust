use crate::tecs_variable::*;
pub struct TTwistWithCovarianceAgedObjectQueue<'a>{
	max_age: i32,
	variable: &'a TECSVariable<TTwistWithCovarianceAgedObjectQueueVar>,
}

pub struct TTwistWithCovarianceAgedObjectQueueVar{
	pub queue: heapless::Queue<(TwistWithCovarianceStamped, i32), 32>,
}

pub struct ESetForTTwistWithCovarianceAgedObjectQueue<'a>{
	pub cell: &'a TTwistWithCovarianceAgedObjectQueue<'a>,
}

pub struct EGetForTTwistWithCovarianceAgedObjectQueue<'a>{
	pub cell: &'a TTwistWithCovarianceAgedObjectQueue<'a>,
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
		queue: Default::default(),
	}
));
pub static ESETFORTWISTWITHCOVARIANCEQUEUE: ESetForTTwistWithCovarianceAgedObjectQueue = ESetForTTwistWithCovarianceAgedObjectQueue {
	cell: &TWISTWITHCOVARIANCEQUEUE,
};

pub static EGETFORTWISTWITHCOVARIANCEQUEUE: EGetForTTwistWithCovarianceAgedObjectQueue = EGetForTTwistWithCovarianceAgedObjectQueue {
	cell: &TWISTWITHCOVARIANCEQUEUE,
};

impl<'a> TTwistWithCovarianceAgedObjectQueue<'a> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut awkernel_lib::sync::mutex::MCSNode<TTwistWithCovarianceAgedObjectQueueVar>) -> LockGuardForTTwistWithCovarianceAgedObjectQueue<'_>
	where
		'b: 'a,
	{
		LockGuardForTTwistWithCovarianceAgedObjectQueue {
			max_age: &self.max_age,
			var: self.variable.lock(node),
		}
	}
}
