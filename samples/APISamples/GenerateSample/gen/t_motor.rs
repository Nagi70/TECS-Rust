use crate::tecs_ex_ctrl::*;
use core::cell::UnsafeCell;
use core::num::NonZeroI32;
use crate::kernel_cfg::*;
pub struct TMotor<'a>
{
	port: PbioPortIdT,
	variable: &'a SyncTMotorVar<'a>,
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

#[link_section = ".rodata"]
pub static MOTORA: TMotor = TMotor {
	port: PbioPortIdT::PbioPortIdA,
	variable: &MOTORAVAR,
};

pub static MOTORAVAR: SyncTMotorVar = SyncTMotorVar {
	/// This UnsafeCell is safe because it is only accessed by one task due to the call flow and component structure of TECS.
	unsafe_var: UnsafeCell::new(TMotorVar {
		motor: None,
	}),
};

#[link_section = ".rodata"]
pub static EMOTORFORMOTORA: EMotorForTMotor = EMotorForTMotor {
	cell: &MOTORA,
};

#[link_section = ".rodata"]
pub static MOTORB: TMotor = TMotor {
	port: PbioPortIdT::PbioPortIdB,
	variable: &MOTORBVAR,
};

pub static MOTORBVAR: SyncTMotorVar = SyncTMotorVar {
	/// This UnsafeCell is safe because it is only accessed by one task due to the call flow and component structure of TECS.
	unsafe_var: UnsafeCell::new(TMotorVar {
		motor: None,
	}),
};

#[link_section = ".rodata"]
pub static EMOTORFORMOTORB: EMotorForTMotor = EMotorForTMotor {
	cell: &MOTORB,
};

impl<'a> TMotor<'a> {
	#[inline]
	pub fn get_cell_ref(&'static self) -> (&'static PbioPortIdT, &'static mut TMotorVar, &TECSDummyLockGuard) {
		(
			&self.port,
			unsafe{&mut *self.variable.unsafe_var.get()},
			&DUMMY_LOCK_GUARD
		)
	}
}
