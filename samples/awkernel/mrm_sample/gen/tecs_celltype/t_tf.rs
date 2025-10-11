pub struct TTf{
	transform: nalgebra::Quaternion<f64>,
}

pub struct ETfForTTf {
	pub cell: &'static TTfstatic IMUCORRECTORTF: TTf = TTf {
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

