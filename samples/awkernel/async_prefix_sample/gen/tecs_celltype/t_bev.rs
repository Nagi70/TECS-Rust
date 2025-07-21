pub struct TBev{
}

pub struct EBevForTBev<'a>{
	pub cell: &'a TBev,
}

pub struct ECmaeraInfoForTBev<'a>{
	pub cell: &'a TBev,
}

static BEV: TBev = TBev {
};

pub static EBEVFORBEV: EBevForTBev = EBevForTBev {
	cell: &BEV,
};

pub static ECMAERAINFOFORBEV: ECmaeraInfoForTBev = ECmaeraInfoForTBev {
	cell: &BEV,
};

