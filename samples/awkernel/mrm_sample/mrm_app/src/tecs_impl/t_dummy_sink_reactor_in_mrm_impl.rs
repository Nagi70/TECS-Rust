use crate::tecs_global::*;
use crate::tecs_celltype::t_dummy_sink_reactor_in_mrm::*;
use crate::tecs_signature::{s_control::*, s_dummy_sink_reactor_in_mrm::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SControl for EControlForTDummySinkReactorInMrm{

	fn send(&'static self, control: &Control) {

	}
}

impl SDummySinkReactorInMrm for EReactorForTDummySinkReactorInMrm{

	fn main(&'static self, control: &Control) {

	}
}

