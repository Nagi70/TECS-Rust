pub struct TPowerdown
{
}

pub struct EPowerdownMForTPowerdown<'a>{
	pub cell: &'a TPowerdown,
}

pub struct EPowerdownSForTPowerdown<'a>{
	pub cell: &'a TPowerdown,
}

#[link_section = ".rodata"]
pub static POWERDOWN: TPowerdown = TPowerdown {
};

#[link_section = ".rodata"]
pub static EPOWERDOWNMFORPOWERDOWN: EPowerdownMForTPowerdown = EPowerdownMForTPowerdown {
	cell: &POWERDOWN,
};

#[link_section = ".rodata"]
pub static EPOWERDOWNSFORPOWERDOWN: EPowerdownSForTPowerdown = EPowerdownSForTPowerdown {
	cell: &POWERDOWN,
};

