use itron::mutex::MutexRef;
use crate::tecs_mutex::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
pub struct TMotor<'a>
{
	port: PbioPortIdT,
	variable: &'a SyncTMotorVar<'a>,
	mutex_ref: &'a TECSMutexRef<'a>,
}

pub struct TMotorVar<'a>{
	pub motor: Option<&'a mut PupMotorT>,
}

pub struct SyncTMotorVar<'a>{
	unsafe_var: UnsafeCell<TMotorVar<'a>>,
}

unsafe impl<'a> Sync for SyncTMotorVar<'a> {}

pub struct EMotorForTMotor<'a>{
	pub cell: &'a TMotor<'a>,
}

pub struct LockGuardForTMotor<'a>{
	mutex_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
pub static MOTOR: TMotor = TMotor {
	port: PbioPortIdT::PbioPortIdA,
	variable: &MOTORVAR,
	mutex_ref: &MOTOR_MUTEX_REF,
};

pub static MOTORVAR: SyncTMotorVar = SyncTMotorVar {
	unsafe_var: UnsafeCell::new(TMotorVar {
		motor: None,
	}),
};

#[link_section = ".rodata"]
pub static MOTOR_MUTEX_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_MUTEX_1).unwrap())},
};

#[link_section = ".rodata"]
pub static EMOTORFORMOTOR: EMotorForTMotor = EMotorForTMotor {
	cell: &MOTOR,
};

impl<'a> Drop for LockGuardForTMotor<'a> {
	fn drop(&mut self){
		self.mutex_ref.unlock();
	}
}

impl<'a> TMotor<'a> {
	#[inline]
	pub fn get_cell_ref(&'static self) -> (&'static PbioPortIdT, &'static mut TMotorVar, LockGuardForTMotor) {
		self.mutex_ref.lock();
		(
			&self.port,
			unsafe{&mut *self.variable.unsafe_var.get()},
			LockGuardForTMotor{
				mutex_ref: self.mutex_ref,
			}
		)
	}
}
