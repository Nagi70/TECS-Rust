pub struct TMahalanobis{
}

pub struct EMahaForTMahalanobis<'a>{
	pub cell: &'a TMahalanobis,
}

static MAHALANOBIS: TMahalanobis = TMahalanobis {
};

pub static EMAHAFORMAHALANOBIS: EMahaForTMahalanobis = EMahaForTMahalanobis {
	cell: &MAHALANOBIS,
};

