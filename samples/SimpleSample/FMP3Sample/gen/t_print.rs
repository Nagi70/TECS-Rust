pub struct TPrint
{
}

pub struct EPrintForTPrint<'a>{
	pub cell: &'a TPrint,
}

#[link_section = ".rodata"]
pub static RPROCESSOR1SYMMETRIC_PRINT1_1: TPrint = TPrint {
};

#[link_section = ".rodata"]
pub static EPRINTFORRPROCESSOR1SYMMETRIC_PRINT1_1: EPrintForTPrint = EPrintForTPrint {
	cell: &RPROCESSOR1SYMMETRIC_PRINT1_1,
};

#[link_section = ".rodata"]
pub static RPROCESSOR2SYMMETRIC_PRINT2_1: TPrint = TPrint {
};

#[link_section = ".rodata"]
pub static EPRINTFORRPROCESSOR2SYMMETRIC_PRINT2_1: EPrintForTPrint = EPrintForTPrint {
	cell: &RPROCESSOR2SYMMETRIC_PRINT2_1,
};

