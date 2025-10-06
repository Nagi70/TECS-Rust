pub struct TUtilsGeometry{
}

pub struct EUtilsForTUtilsGeometry<'a>{
	pub cell: &'a TUtilsGeometry,
}

static UTILSGEOMETRY: TUtilsGeometry = TUtilsGeometry {
};

pub static EUTILSFORUTILSGEOMETRY: EUtilsForTUtilsGeometry = EUtilsForTUtilsGeometry {
	cell: &UTILSGEOMETRY,
};

