use crate::tecs_variable::*;
pub struct TRateBoundStatus{
	reference_hz: f64,
	ok_min_hz: f64,
	ok_max_hz: f64,
	warn_min_hz: f64,
	warn_max_hz: f64,
	num_frame_transition: u32,
	variable: &'a TECSVariable<TRateBoundStatus>,
}

pub struct TRateBoundStatusVar{
	pub last_stamp: Time,
	pub frequency: f64,
	pub zero_seen: bool,
}

pub struct ERateForTRateBoundStatus<'a>{
	pub cell: &'a TRateBoundStatus,
}

pub struct LockGuardForTRateBoundStatus<'a>{
	pub reference_hz: &'a f64,
	pub ok_min_hz: &'a f64,
	pub ok_max_hz: &'a f64,
	pub warn_min_hz: &'a f64,
	pub warn_max_hz: &'a f64,
	pub num_frame_transition: &'a u32,
	pub var: TECSVarGuard<'a, TRateBoundStatus>,
}

static IMUDRIVERDIAG: TRateBoundStatus = TRateBoundStatus {
	reference_hz: 200.0,
	ok_min_hz: 100.0,
	ok_max_hz: 10000.0,
	warn_min_hz: 50.0,
	warn_max_hz: 100000.0,
	num_frame_transition: 2,
	variable: &IMUDRIVERDIAGVAR,
};

static IMUDRIVERDIAGVAR: TECSVariable<TRateBoundStatus> = TECSVariable::Raw(TECSSyncVar { unsafe_var: UnsafeCell::new(
	TRateBoundStatus {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		last_stamp: awkernel_lib::time::Time::zero(),
		frequency: 0.0,
		zero_seen: false,
	}),
});

pub static ERATEFORIMUDRIVERDIAG: ERateForTRateBoundStatus = ERateForTRateBoundStatus {
	cell: &IMUDRIVERDIAG,
};

impl<> TRateBoundStatus {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TRateBoundStatus>) -> LockGuardForTRateBoundStatus
	where
		'b: 'a,
	{
		LockGuardForTRateBoundStatus {
			reference_hz: &self.reference_hz,
			ok_min_hz: &self.ok_min_hz,
			ok_max_hz: &self.ok_max_hz,
			warn_min_hz: &self.warn_min_hz,
			warn_max_hz: &self.warn_max_hz,
			num_frame_transition: &self.num_frame_transition,
			var: self.variable.lock(node),
		}
	}
}
