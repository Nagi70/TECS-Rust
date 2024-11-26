use itron::mutex::MutexRef;
use crate::tecs_mutex::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
pub struct TSensor<'a>
{
	port: PbioPortIdT,
	variable: &'a SyncTSensorVar<'a>,
	mutex_ref: &'a TECSMutexRef<'a>,
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
	mutex_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
pub static SENSOR: TSensor = TSensor {
	port: PbioPortIdT::PbioPortIdC,
	variable: &SENSORVAR,
	mutex_ref: &SENSOR_MUTEX_REF,
};

pub static SENSORVAR: SyncTSensorVar = SyncTSensorVar {
	unsafe_var: UnsafeCell::new(TSensorVar {
		ult: None,
	}),
};

#[link_section = ".rodata"]
pub static SENSOR_MUTEX_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_MUTEX_2).unwrap())},
};

#[link_section = ".rodata"]
pub static ESENSORFORSENSOR: ESensorForTSensor = ESensorForTSensor {
	cell: &SENSOR,
};

impl<'a> Drop for LockGuardForTSensor<'a> {
	fn drop(&mut self){
		self.mutex_ref.unlock();
	}
}

impl<'a> TSensor<'a> {
	#[inline]
	pub fn get_cell_ref(&'static self) -> (&'static PbioPortIdT, &'static mut TSensorVar, LockGuardForTSensor) {
		self.mutex_ref.lock();
		(
			&self.port,
			unsafe{&mut *self.variable.unsafe_var.get()},
			LockGuardForTSensor{
				mutex_ref: self.mutex_ref,
			}
		)
	}
}
