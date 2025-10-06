use crate::tecs_struct_def::*;
pub trait SLowpass1d {
	fn filter(&'static self, value: &f64, filtered: &mut f64);
}
