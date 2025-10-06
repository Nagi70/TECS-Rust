pub struct TCovariance{
}

pub struct ECovForTCovariance<'a>{
	pub cell: &'a TCovariance,
}

static COVARIANCE: TCovariance = TCovariance {
};

pub static ECOVFORCOVARIANCE: ECovForTCovariance = ECovForTCovariance {
	cell: &COVARIANCE,
};

