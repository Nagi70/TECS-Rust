use crate::tecs_global::*;
use crate::tecs_celltype::t_dummy::*;
use crate::tecs_signature::{s_dummy::*, s_int::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SDummy for EReactorForTDummy<'_>{

	fn main(&'static self, value: &i32) {

	}
}

impl SInt for EIntForTDummy<'_>{

	fn send(&'static self, value: &i32) {

	}
}

