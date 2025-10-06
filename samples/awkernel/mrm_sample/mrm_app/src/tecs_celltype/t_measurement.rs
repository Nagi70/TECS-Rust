pub struct TMeasurement{
}

pub struct EMeasureForTMeasurement<'a>{
	pub cell: &'a TMeasurement,
}

static MEASUREMENT: TMeasurement = TMeasurement {
};

pub static EMEASUREFORMEASUREMENT: EMeasureForTMeasurement = EMeasureForTMeasurement {
	cell: &MEASUREMENT,
};

