use itron::mutex::MutexRef;
use itron::semaphore::SemaphoreRef;
use crate::tecs_ex_ctrl::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
pub struct TMotor<'a>
{
	port: PbioPortIdT,
	variable: &'a SyncTMotorVar<'a>,
	ex_ctrl_ref: &'a (dyn LockManager + Sync + Send),
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
	ex_ctrl_ref: &'a (dyn LockManager + Sync + Send),
}

#[link_section = ".rodata"]
pub static MOTOR1: TMotor = TMotor {
	port: PbioPortIdT::PbioPortIdA,
	variable: &MOTOR1VAR,
	ex_ctrl_ref: &DUMMY_EX_CTRL_REF,
};

pub static MOTOR1VAR: SyncTMotorVar = SyncTMotorVar {
	/// This UnsafeCell is safe because it is only accessed by one task due to the call flow and component structure of TECS.
	unsafe_var: UnsafeCell::new(TMotorVar {
		motor: None,
	}),
};

#[link_section = ".rodata"]
pub static EMOTORFORMOTOR1: EMotorForTMotor = EMotorForTMotor {
	cell: &MOTOR1,
};

#[link_section = ".rodata"]
pub static MOTOR2: TMotor = TMotor {
	port: PbioPortIdT::PbioPortIdB,
	variable: &MOTOR2VAR,
	ex_ctrl_ref: &MOTOR2_EX_CTRL_REF,
};

pub static MOTOR2VAR: SyncTMotorVar = SyncTMotorVar {
	/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
	unsafe_var: UnsafeCell::new(TMotorVar {
		motor: None,
	}),
};

#[link_section = ".rodata"]
pub static MOTOR2_EX_CTRL_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_1).unwrap())},
};

#[link_section = ".rodata"]
pub static EMOTORFORMOTOR2: EMotorForTMotor = EMotorForTMotor {
	cell: &MOTOR2,
};

impl<'a> Drop for LockGuardForTMotor<'a> {
	fn drop(&mut self){
		self.ex_ctrl_ref.unlock();
	}
}

impl<'a> TMotor<'a> {
	#[inline]
	pub fn get_cell_ref(&'static self) -> (&'static PbioPortIdT, &'static mut TMotorVar, LockGuardForTMotor) {
		self.ex_ctrl_ref.lock();
		(
			&self.port,
			unsafe{&mut *self.variable.unsafe_var.get()},
			LockGuardForTMotor{
				ex_ctrl_ref: self.ex_ctrl_ref,
			}
		)
	}
}
