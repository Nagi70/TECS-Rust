use crate::tecs_global::*;
use crate::tecs_celltype::t_lowpass_filter1_d::*;
use crate::tecs_signature::s_lowpass1d::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SLowpass1d for EFilterForTLowpassFilter1D{

	fn filter(&self, value: &f64, filtered: &mut f64) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let u = *value;
		let g = *lg.gain;

		let ret = if let Some(prev) = lg.var.x {
			let r = g * prev + (1.0 - g) * u;
			lg.var.x = Some(r);
			r
		} else {
			lg.var.x = Some(u);
			u
		};

		*filtered = ret;
	}
}

