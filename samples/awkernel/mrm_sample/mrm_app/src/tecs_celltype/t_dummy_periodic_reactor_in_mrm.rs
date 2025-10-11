use crate::tecs_variable::*;
use crate::tecs_global::*;
use crate::tecs_signature::{s_imu::*, s_velocity_status::*};

use crate::tecs_celltype::{t_imu_driver::*, t_vehicle_velocity_converter::*};

pub struct TDummyPeriodicReactorInMrm{
	variable: &'static TECSVariable<TDummyPeriodicReactorInMrmVar>,
}

pub struct TDummyPeriodicReactorInMrmVar {
	pub i: i32,
}

pub struct EReactorForTDummyPeriodicReactorInMrm {
	pub cell: &'static TDummyPeriodicReactorInMrm,
}

pub struct LockGuardForTDummyPeriodicReactorInMrm<'a>{
	pub var: TECSVarGuard<'a, TDummyPeriodicReactorInMrmVar>,
}

static DUMMYHARDWARE: TDummyPeriodicReactorInMrm = TDummyPeriodicReactorInMrm {
	variable: &DUMMYHARDWAREVAR,
};

static DUMMYHARDWAREVAR: TECSVariable<TDummyPeriodicReactorInMrmVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TDummyPeriodicReactorInMrmVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
	i: 0,
	}
));
pub static EREACTORFORDUMMYHARDWARE: EReactorForTDummyPeriodicReactorInMrm = EReactorForTDummyPeriodicReactorInMrm {
	cell: &DUMMYHARDWARE,
};

impl TDummyPeriodicReactorInMrm {
	#[inline]
	pub fn get_cell_ref<'node>(&'static self, node: &'node mut awkernel_lib::sync::mutex::MCSNode<TDummyPeriodicReactorInMrmVar>) -> LockGuardForTDummyPeriodicReactorInMrm<'node> {
		LockGuardForTDummyPeriodicReactorInMrm {
			var: self.variable.lock(node),
		}
	}
}
