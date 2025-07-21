pub struct TGyroOdometer{
}

pub struct EGyroOdometerForTGyroOdometer<'a>{
	pub cell: &'a TGyroOdometer,
}

#[link_section = ".rodata"]
pub static ODOMETER: TGyroOdometer = TGyroOdometer {
};

#[link_section = ".rodata"]
pub static EGYROODOMETERFORODOMETER: EGyroOdometerForTGyroOdometer = EGyroOdometerForTGyroOdometer {
	cell: &ODOMETER,
};

