use core::cell::UnsafeCell;
use crate::tecs_mutex::*;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
use spin::Mutex;
pub struct TMotor<'a>
{
	port: PbioPortIdT,
	variable: SyncTMotorVar<'a>,
	mutex_ref: &'a (dyn LockableForMutex + Sync + Send),
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
	mutex_ref: &'a (dyn LockableForMutex + Sync + Send),
}

#[link_section = ".rodata"]
pub static MOTOR1: TMotor = TMotor {
	port: PbioPortIdT::PBIO_PORT_ID_A,
	variable: &MOTOR1VAR,
	mutex_ref: &DUMMY_MUTEX_REF,
};

pub static MOTOR1VAR: SyncTMotorVar = SyncTMotorVar {
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
	port: PbioPortIdT::PBIO_PORT_ID_B,
	variable: &MOTOR2VAR,
	mutex_ref: &MOTOR2_MUTEX_REF,
};

pub static MOTOR2VAR: SyncTMotorVar = SyncTMotorVar {
	unsafe_var: UnsafeCell::new(TMotorVar {
		motor: None,
	}),
};

#[link_section = ".rodata"]
pub static MOTOR2_MUTEX_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZero::new(TECS_RUST_MUTEX_1).unwrap())},
};

#[link_section = ".rodata"]
pub static EMOTORFORMOTOR2: EMotorForTMotor = EMotorForTMotor {
	cell: &MOTOR2,
};

impl<'a> Drop for LockGuardForTMotor<'a> {
	fn drop(&mut self){
		self.mutex_ref.unlock();
	}
}

impl'a,  TMotor<'a> {
	#[inline]
	pub fn get_cell_ref<'a>(&'static self) -> (&PbioPortIdT, &mut TMotorVar, LockGuardForTMotor) {
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
