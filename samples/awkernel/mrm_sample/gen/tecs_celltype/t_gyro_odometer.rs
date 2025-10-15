use crate::tecs_variable::*;
use crate::tecs_global::*;
use crate::tecs_signature::{s_twist_with_covariance_stamped::*, s_tf::*};

use crate::tecs_celltype::{t_ekf_localizer::*, t_tf::*};

pub struct TGyroOdometer<T>
where
	T: STf + 'static,
{
	c_tf: &'static T,
	output_frame: &'static str,
	variable: &'static TECSVariable<TGyroOdometerVar>,
}

pub struct TGyroOdometerVar {
	pub imu_covariance: nalgebra::Matrix3<f64>,
}

pub struct ETwistWithCovarianceVForTGyroOdometer {
	pub cell: &'static TGyroOdometer<ETfForTTf>,
}

pub struct EImuDataForTGyroOdometer {
	pub cell: &'static TGyroOdometer<ETfForTTf>,
}

pub struct EReactorForTGyroOdometer {
	pub cell: &'static TGyroOdometer<ETfForTTf>,
}

pub struct LockGuardForTGyroOdometer<'a, T>
where
	T: STf + 'static,
{
	pub c_tf: &'a T,
	pub output_frame: &'a &'static str,
	pub var: TECSVarGuard<'a, TGyroOdometerVar>,
}

static GYROODOMETER: TGyroOdometer<ETfForTTf> = TGyroOdometer {
	c_tf: &ETFFORGYROODOMETERTF,
	output_frame: "base_link",
	variable: &GYROODOMETERVAR,
};

static GYROODOMETERVAR: TECSVariable<TGyroOdometerVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TGyroOdometerVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
	imu_covariance: nalgebra::Matrix3::new(0.0, 0.0, 0.0,0.0, 0.0, 0.0,0.0, 0.0, 0.0),
	}
));
pub static ETWISTWITHCOVARIANCEVFORGYROODOMETER: ETwistWithCovarianceVForTGyroOdometer = ETwistWithCovarianceVForTGyroOdometer {
	cell: &GYROODOMETER,
};

pub static EIMUDATAFORGYROODOMETER: EImuDataForTGyroOdometer = EImuDataForTGyroOdometer {
	cell: &GYROODOMETER,
};

pub static EREACTORFORGYROODOMETER: EReactorForTGyroOdometer = EReactorForTGyroOdometer {
	cell: &GYROODOMETER,
};

impl<T: STf> TGyroOdometer<T> {
	#[inline]
	pub fn get_cell_ref<'node>(&'static self, node: &'node mut awkernel_lib::sync::mutex::MCSNode<TGyroOdometerVar>) -> LockGuardForTGyroOdometer<'node, T> {
		LockGuardForTGyroOdometer {
			c_tf: self.c_tf,
			output_frame: &self.output_frame,
			var: self.variable.lock(node),
		}
	}
}
