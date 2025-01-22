use itron::mutex::MutexRef;
use crate::tecs_ex_ctrl::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
pub struct TSensor<'a>
{
	port: PbioPortIdT,
	variable: &'a SyncTSensorVar<'a>,
	ex_ctrl_ref: &'a TECSMutexRef<'a>,
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
	ex_ctrl_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
pub static SENSOR: TSensor = TSensor {
	port: PbioPortIdT::PbioPortIdC,
	variable: &SENSORVAR,
	ex_ctrl_ref: &SENSOR_EX_CTRL_REF,
};

pub static SENSORVAR: SyncTSensorVar = SyncTSensorVar {
	/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
	unsafe_var: UnsafeCell::new(TSensorVar {
		ult: None,
	}),
};

#[link_section = ".rodata"]
pub static SENSOR_EX_CTRL_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_3).unwrap())},
};

#[link_section = ".rodata"]
pub static ESENSORFORSENSOR: ESensorForTSensor = ESensorForTSensor {
	cell: &SENSOR,
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
