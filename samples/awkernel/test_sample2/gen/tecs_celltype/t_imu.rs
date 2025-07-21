pub struct TImu{
}

pub struct EImuForTImu<'a>{
	pub cell: &'a TImu,
}

#[link_section = ".rodata"]
static IMU: TImu = TImu {
};

#[link_section = ".rodata"]
pub static EIMUFORIMU: EImuForTImu = EImuForTImu {
	cell: &IMU,
};

