pub struct TPowerdown
{
}

pub struct EPowerdown1ForTPowerdown<'a>{
	pub cell: &'a TPowerdown,
}

pub struct EPowerdown2ForTPowerdown<'a>{
	pub cell: &'a TPowerdown,
}

#[link_section = ".rodata"]
pub static POWERDOWN: TPowerdown = TPowerdown {
};

#[link_section = ".rodata"]
pub static EPOWERDOWN1FORPOWERDOWN: EPowerdown1ForTPowerdown = EPowerdown1ForTPowerdown {
	cell: &POWERDOWN,
};

#[link_section = ".rodata"]
pub static EPOWERDOWN2FORPOWERDOWN: EPowerdown2ForTPowerdown = EPowerdown2ForTPowerdown {
	cell: &POWERDOWN,
};

