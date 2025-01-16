pub struct TSensorB
{
}

pub struct ESensorForTSensorB<'a>{
	pub cell: &'a TSensorB,
}

#[link_section = ".rodata"]
pub static SENSORB: TSensorB = TSensorB {
};

#[link_section = ".rodata"]
pub static ESENSORFORSENSORB: ESensorForTSensorB = ESensorForTSensorB {
	cell: &SENSORB,
};

