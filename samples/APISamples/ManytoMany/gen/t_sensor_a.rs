pub struct TSensorA
{
}

pub struct ESensorForTSensorA<'a>{
	pub cell: &'a TSensorA,
}

#[link_section = ".rodata"]
pub static SENSORA: TSensorA = TSensorA {
};

#[link_section = ".rodata"]
pub static ESENSORFORSENSORA: ESensorForTSensorA = ESensorForTSensorA {
	cell: &SENSORA,
};

