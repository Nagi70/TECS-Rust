use itron::mutex::MutexRef;
use crate::tecs_ex_ctrl::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
pub struct TMotor<'a>
{
	port: PbioPortIdT,
	variable: &'a SyncTMotorVar<'a>,
	ex_ctrl_ref: &'a TECSMutexRef<'a>,
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
	ex_ctrl_ref: &'a TECSMutexRef<'a>,
}

#[link_section = ".rodata"]
pub static MOTORA: TMotor = TMotor {
	port: PbioPortIdT::PbioPortIdA,
	variable: &MOTORAVAR,
	ex_ctrl_ref: &MOTORA_EX_CTRL_REF,
};

pub static MOTORAVAR: SyncTMotorVar = SyncTMotorVar {
	/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
	unsafe_var: UnsafeCell::new(TMotorVar {
		motor: None,
	}),
};

#[link_section = ".rodata"]
pub static MOTORA_EX_CTRL_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_1).unwrap())},
};

#[link_section = ".rodata"]
pub static EMOTORFORMOTORA: EMotorForTMotor = EMotorForTMotor {
	cell: &MOTORA,
};

#[link_section = ".rodata"]
pub static MOTORB: TMotor = TMotor {
	port: PbioPortIdT::PbioPortIdB,
	variable: &MOTORBVAR,
	ex_ctrl_ref: &MOTORB_EX_CTRL_REF,
};

pub static MOTORBVAR: SyncTMotorVar = SyncTMotorVar {
	/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
	unsafe_var: UnsafeCell::new(TMotorVar {
		motor: None,
	}),
};

#[link_section = ".rodata"]
pub static MOTORB_EX_CTRL_REF: TECSMutexRef = TECSMutexRef{
	inner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_2).unwrap())},
};

#[link_section = ".rodata"]
pub static EMOTORFORMOTORB: EMotorForTMotor = EMotorForTMotor {
	cell: &MOTORB,
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
