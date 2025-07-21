use itron::task::TaskRef;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use itron::mutex::MutexRef;
use crate::tecs_ex_ctrl::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::tecs_signature::{s_sink_reactorbody::*, s_pubsub::*};

use crate::tecs_celltype::{t_gyro_odometer::*, t_pubsub::*};

pub struct TSinkReactor<'a, T, U>
where
	T: SSinkReactorbody,
	U: SPubsub,
{
	c_taskbody: &'a T,
	c_subscriber: &'a U,
	name: Cow,
	variable: &'a SyncTSinkReactorVar,
	ex_ctrl_ref: &'a TECSMutexRef<'a>,
}

pub struct TSinkReactorVar{
	pub unsafeVar: u32,
}

pub struct SyncTSinkReactorVar{
	unsafe_var: UnsafeCell<TSinkReactorVar>,
}

unsafe impl Sync for SyncTSinkReactorVar {}

pub struct ETaskForTSinkReactor<'a>{
	pub cell: &'a TSinkReactor<'a, EGyroOdometerForTGyroOdometer<'a>, EPubsubForTPubsub<'a>>,
}

pub struct LockGuardForTSinkReactor<'a, T, U>
where
	T: SSinkReactorbody,
	U: SPubsub,
{
	pub c_taskbody: &'a T,
	pub c_subscriber: &'a U,
	pub name: &'a Cow,
	pub var: &'a mut TSinkReactorVar,
	ex_ctrl_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
static SINKREACTOR: TSinkReactor<EGyroOdometerForTGyroOdometer, EPubsubForTPubsub> = TSinkReactor {
	c_taskbody: &EGYROODOMETERFORODOMETER,
	c_subscriber: &EPUBSUBFORTOPIC2,
	name: sink_reactor,
	variable: &SINKREACTORVAR,
	ex_ctrl_ref: &SINKREACTOR_EX_CTRL_REF,
};

static SINKREACTORVAR: SyncTSinkReactorVar = SyncTSinkReactorVar {
	/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
	unsafe_var: UnsafeCell::new(TSinkReactorVar {
		unsafeVar: 0,
	}),
};

#[link_section = ".rodata"]
static SINKREACTOR_EX_CTRL_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_2).unwrap())},
};

#[link_section = ".rodata"]
pub static ETASKFORSINKREACTOR: ETaskForTSinkReactor = ETaskForTSinkReactor {
	cell: &SINKREACTOR,
};

impl<T: SSinkReactorbody, U: SPubsub> Drop for LockGuardForTSinkReactor<'_, T, U> {
	fn drop(&mut self){
		self.ex_ctrl_ref.unlock();
	}
}

impl<T: SSinkReactorbody, U: SPubsub> TSinkReactor<'_, T, U> {
	pub fn get_cell_ref(&'static self) -> LockGuardForTSinkReactor<'_, T, U> {
		self.ex_ctrl_ref.lock();
		LockGuardForTSinkReactor {
			c_taskbody: self.c_taskbody,
			c_subscriber: self.c_subscriber,
			name: &self.name,
			var: unsafe{&mut *self.variable.unsafe_var.get()},
			ex_ctrl_ref: self.ex_ctrl_ref,
		}
	}
}
