pub struct TImuCorrector{
}

pub struct EImuCorrectorForTImuCorrector<'a>{
	pub cell: &'a TImuCorrector,
}

#[link_section = ".rodata"]
static CORRECTOR: TImuCorrector = TImuCorrector {
};

#[link_section = ".rodata"]
pub static EIMUCORRECTORFORCORRECTOR: EImuCorrectorForTImuCorrector = EImuCorrectorForTImuCorrector {
	cell: &CORRECTOR,
};

