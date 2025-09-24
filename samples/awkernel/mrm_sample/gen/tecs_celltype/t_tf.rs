pub struct TTf{
	transform: nalgebra::Quaternion<f64>,
}

pub struct ETfForTTf<'a>{
	pub cell: &'a TTf,
}

pub struct LockGuardForTTf<'a>{
	pub transform: &'a nalgebra::Quaternion<f64>,
}

static IMUCORRECTORTF: TTf = TTf {
	transform: nalgebra::Quaternion::new(1.0, 2.0, 1.0, 2.0),
};

pub static ETFFORIMUCORRECTORTF: ETfForTTf = ETfForTTf {
	cell: &IMUCORRECTORTF,
};

static GYROODOMETERTF: TTf = TTf {
	transform: nalgebra::Quaternion::new(2.0, 1.0, 2.0, 1.0),
};

pub static ETFFORGYROODOMETERTF: ETfForTTf = ETfForTTf {
	cell: &GYROODOMETERTF,
};

impl<'a> TTf {
	#[inline]
	pub fn get_cell_ref(&'a self) -> LockGuardForTTf	{
		LockGuardForTTf {
			transform: &self.transform,
		}
	}
}
