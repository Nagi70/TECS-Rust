use crate::tecs_global::*;
use crate::tecs_celltype::t_measurement::*;
use crate::tecs_signature::s_measurement::*;
use awkernel_lib::sync::mutex::MCSNode;
impl SMeasurement for EMeasureForTMeasurement<'_>{

	fn twist_measurement_matrix(&'static self) -> nalgebra::Matrix2x6<f64>{
		// 2x6 zero matrix, select vx and wz from the 6D state
		let mut c = nalgebra::Matrix2x6::<f64>::zeros();
		c[(0, IDX_VX as usize)] = 1.0; // for vx
		c[(1, IDX_WZ as usize)] = 1.0; // for wz
		c
	}
	fn twist_measurement_covariance(&'static self, covariance: &nalgebra::Matrix6<f64>, smoothing_step: &u32) -> nalgebra::Matrix2<f64>{
		// Extract the relevant 2x2 block from XYZRPY 6x6 covariance (x index = 0, yaw index = 5)
		let mut r = nalgebra::Matrix2::<f64>::zeros();
		r[(0, 0)] = covariance[(IDX_X, IDX_X)];
		r[(0, 1)] = covariance[(IDX_X, IDX_YAW)];
		r[(1, 0)] = covariance[(IDX_YAW, IDX_X)];
		r[(1, 1)] = covariance[(IDX_YAW, IDX_YAW)];
		r * (*smoothing_step as f64)
	}
}

