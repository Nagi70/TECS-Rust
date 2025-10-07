use crate::tecs_global::*;
pub trait SLowpass1d {
	fn filter(&'static self, value: &f64, filtered: &mut f64);
}
