pub struct TStateTransition{
}

pub struct EStateForTStateTransition<'a>{
	pub cell: &'a TStateTransition,
}

static STATETRANSITION: TStateTransition = TStateTransition {
};

pub static ESTATEFORSTATETRANSITION: EStateForTStateTransition = EStateForTStateTransition {
	cell: &STATETRANSITION,
};

