use itron::mutex::MutexRef;
use itron::semaphore::SemaphoreRef;
use crate::tecs_ex_ctrl::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
pub struct TSensor<'a>
{
	port: PbioPortIdT,
	variable: &'a SyncTSensorVar<'a>,
	ex_ctrl_ref: &'a (dyn LockManager + Sync + Send),
}

pub struct TSensorVar<'a>{
	pub ult: Option<&'a mut PupUltrasonicSensorT>,
}

pub struct SyncTSensorVar<'a>{
	unsafe_var: UnsafeCell<TSensorVar<'a>>,
}

unsafe impl<'a> Sync for SyncTSensorVar<'a> {}

pub struct ESensorForTSensor<'a>{
	pub cell: &'a TSensor<'a>,
}

pub struct LockGuardForTSensor<'a>{
	ex_ctrl_ref: &'a (dyn LockManager + Sync + Send),
}

#[link_section = ".rodata"]
pub static SENSOR1: TSensor = TSensor {
	port: PbioPortIdT::PbioPortIdC,
	variable: &SENSOR1VAR,
	ex_ctrl_ref: &DUMMY_EX_CTRL_REF,
};

pub static SENSOR1VAR: SyncTSensorVar = SyncTSensorVar {
	/// This UnsafeCell is safe because it is only accessed by one task due to the call flow and component structure of TECS.
	unsafe_var: UnsafeCell::new(TSensorVar {
		ult: None,
	}),
};

#[link_section = ".rodata"]
pub static ESENSORFORSENSOR1: ESensorForTSensor = ESensorForTSensor {
	cell: &SENSOR1,
};

#[link_section = ".rodata"]
pub static SENSOR2: TSensor = TSensor {
	port: PbioPortIdT::PbioPortIdD,
	variable: &SENSOR2VAR,
	ex_ctrl_ref: &SENSOR2_EX_CTRL_REF,
};

pub static SENSOR2VAR: SyncTSensorVar = SyncTSensorVar {
	/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the semaphore object.
	unsafe_var: UnsafeCell::new(TSensorVar {
		ult: None,
	}),
};

#[link_section = ".rodata"]
pub static SENSOR2_EX_CTRL_REF: TECSSemaphoreRef = TECSSemaphoreRef{
	inner: unsafe{SemaphoreRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_2).unwrap())},
};

#[link_section = ".rodata"]
pub static ESENSORFORSENSOR2: ESensorForTSensor = ESensorForTSensor {
	cell: &SENSOR2,
};

impl<'a> Drop for LockGuardForTSensor<'a> {
	fn drop(&mut self){
		self.ex_ctrl_ref.unlock();
	}
}

impl<'a> TSensor<'a> {
	#[inline]
	pub fn get_cell_ref(&'static self) -> (&'static PbioPortIdT, &'static mut TSensorVar, LockGuardForTSensor) {
		self.ex_ctrl_ref.lock();
		(
			&self.port,
			unsafe{&mut *self.variable.unsafe_var.get()},
			LockGuardForTSensor{
				ex_ctrl_ref: self.ex_ctrl_ref,
			}
		)
	}
}
