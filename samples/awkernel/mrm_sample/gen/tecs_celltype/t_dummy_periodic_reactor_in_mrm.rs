use crate::tecs_variable::*;
use crate::tecs_struct_def::*;
use crate::tecs_signature::{s_imu::*, s_velocity_status::*};

use crate::tecs_celltype::{t_imu_driver::*, t_vehicle_velocity_converter::*};

pub struct TDummyPeriodicReactorInMrm<'a>{
	variable: &'a TECSVariable<TDummyPeriodicReactorInMrmVar>,
}

pub struct TDummyPeriodicReactorInMrmVar{
	pub i: i32,
}

pub struct EReactorForTDummyPeriodicReactorInMrm<'a>{
	pub cell: &'a TDummyPeriodicReactorInMrm<'a>,
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

impl<'a> TDummyPeriodicReactorInMrm<'a> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut awkernel_lib::sync::mutex::MCSNode<TDummyPeriodicReactorInMrmVar>) -> LockGuardForTDummyPeriodicReactorInMrm<'_>
	where
		'b: 'a,
	{
		LockGuardForTDummyPeriodicReactorInMrm {
			var: self.variable.lock(node),
		}
	}
}
