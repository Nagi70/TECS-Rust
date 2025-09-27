use crate::tecs_variable::*;
use crate::tecs_struct_def::*;
use crate::tecs_signature::{s_twist_with_covariance_stamped::*, s_tf::*};

use crate::tecs_celltype::{t_ekf_localizer::*, t_tf::*};

pub struct TGyroOdometer<'a, T>
where
	T: STf,
{
	c_tf: &'a T,
	output_frame: &'static str,
	variable: &'a TECSVariable<TGyroOdometerVar>,
}

pub struct TGyroOdometerVar{
	pub imu_covariance: nalgebra::Matrix3<f64>,
}

pub struct ETwistWithCovarianceVForTGyroOdometer<'a>{
	pub cell: &'a TGyroOdometer<'a, ETfForTTf<'a>>,
}

pub struct EImuDataForTGyroOdometer<'a>{
	pub cell: &'a TGyroOdometer<'a, ETfForTTf<'a>>,
}

pub struct EReactorForTGyroOdometer<'a>{
	pub cell: &'a TGyroOdometer<'a, ETfForTTf<'a>>,
}

pub struct LockGuardForTGyroOdometer<'a, T>
where
	T: STf,
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
		imu_covariance: Default::default,
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

impl<'a, T: STf> TGyroOdometer<'a, T> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut awkernel_lib::sync::mutex::MCSNode<TGyroOdometerVar>) -> LockGuardForTGyroOdometer<'_, T>
	where
		'b: 'a,
	{
		LockGuardForTGyroOdometer {
			c_tf: self.c_tf,
			output_frame: &self.output_frame,
			var: self.variable.lock(node),
		}
	}
}
