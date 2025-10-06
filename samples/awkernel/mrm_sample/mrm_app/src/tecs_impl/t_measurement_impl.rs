use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_measurement::*;
use crate::tecs_signature::s_measurement::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SMeasurement for EMeasureForTMeasurement<'_>{

	fn twist_measurement_matrix(&'static self) -> nalgebra::Matrix2x6<f64>{

	}
	fn twist_measurement_covariance(&'static self, covairance: &nalgebra::Matrix6<f64>, smoothing_step: &u32) -> nalgebra::Matrix2<f64>{

	}
}

