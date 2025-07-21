use itron::task::TaskRef;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use itron::mutex::MutexRef;
use crate::tecs_ex_ctrl::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use crate::tecs_signature::{s_reactorbody::*, s_pubsub::*};

use crate::tecs_celltype::{t_imu_corrector::*, t_pubsub::*};

pub struct TReactor<'a, T, U, V>
where
	T: SReactorbody,
	U: SPubsub,
	V: SPubsub,
{
	c_taskbody: &'a T,
	c_publisher: &'a U,
	c_subscriber: &'a V,
	name: Cow,
	variable: &'a SyncTReactorVar,
	ex_ctrl_ref: &'a TECSMutexRef<'a>,
}

pub struct TReactorVar{
	pub unsafeVar: u32,
}

pub struct SyncTReactorVar{
	unsafe_var: UnsafeCell<TReactorVar>,
}

unsafe impl Sync for SyncTReactorVar {}

pub struct ETaskForTReactor<'a>{
	pub cell: &'a TReactor<'a, EImuCorrectorForTImuCorrector<'a>, EPubsubForTPubsub<'a>, EPubsubForTPubsub<'a>>,
}

pub struct LockGuardForTReactor<'a, T, U, V>
where
	T: SReactorbody,
	U: SPubsub,
	V: SPubsub,
{
	pub c_taskbody: &'a T,
	pub c_publisher: &'a U,
	pub c_subscriber: &'a V,
	pub name: &'a Cow,
	pub var: &'a mut TReactorVar,
	ex_ctrl_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
static REACTOR: TReactor<EImuCorrectorForTImuCorrector, EPubsubForTPubsub, EPubsubForTPubsub> = TReactor {
	c_taskbody: &EIMUCORRECTORFORCORRECTOR,
	c_publisher: &EPUBSUBFORTOPIC2,
	c_subscriber: &EPUBSUBFORTOPIC1,
	name: reactor,
	variable: &REACTORVAR,
	ex_ctrl_ref: &REACTOR_EX_CTRL_REF,
};

static REACTORVAR: SyncTReactorVar = SyncTReactorVar {
	/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
	unsafe_var: UnsafeCell::new(TReactorVar {
		unsafeVar: 0,
	}),
};

#[link_section = ".rodata"]
static REACTOR_EX_CTRL_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_1).unwrap())},
};

#[link_section = ".rodata"]
pub static ETASKFORREACTOR: ETaskForTReactor = ETaskForTReactor {
	cell: &REACTOR,
};

impl<T: SReactorbody, U: SPubsub, V: SPubsub> Drop for LockGuardForTReactor<'_, T, U, V> {
	fn drop(&mut self){
		self.ex_ctrl_ref.unlock();
	}
}

impl<T: SReactorbody, U: SPubsub, V: SPubsub> TReactor<'_, T, U, V> {
	pub fn get_cell_ref(&'static self) -> LockGuardForTReactor<'_, T, U, V> {
		self.ex_ctrl_ref.lock();
		LockGuardForTReactor {
			c_taskbody: self.c_taskbody,
			c_publisher: self.c_publisher,
			c_subscriber: self.c_subscriber,
			name: &self.name,
			var: unsafe{&mut *self.variable.unsafe_var.get()},
			ex_ctrl_ref: self.ex_ctrl_ref,
		}
	}
}
