use crate::tecs_variable::*;
use crate::tecs_struct_def::*;
use crate::tecs_signature::{s_imu_data::*, s_tf::*};

use crate::tecs_celltype::{t_gyro_odometer::*, t_tf::*};

pub struct TImuCorrector<'a, T>
where
	T: STf,
{
	c_tf: &'a T,
	output_frame: &'static str,
	angular_velocity_offset_x: f64,
	angular_velocity_offset_y: f64,
	angular_velocity_offset_z: f64,
	angular_velocity_stddev_xx: f64,
	angular_velocity_stddev_yy: f64,
	angular_velocity_stddev_zz: f64,
	accel_stddev: f64,
	variable: &'a TECSVariable<TImuCorrectorVar>,
}

pub struct TImuCorrectorVar{
	pub linear_acceleration_covariance: nalgebra::Matrix3<f64>,
	pub angular_velocity_covariance: nalgebra::Matrix3<f64>,
}

pub struct EImuRawForTImuCorrector<'a>{
	pub cell: &'a TImuCorrector<'a, ETfForTTf<'a>>,
}

pub struct EReactorForTImuCorrector<'a>{
	pub cell: &'a TImuCorrector<'a, ETfForTTf<'a>>,
}

pub struct LockGuardForTImuCorrector<'a, T>
where
	T: STf,
{
	pub c_tf: &'a T,
	pub output_frame: &'a &'static str,
	pub angular_velocity_offset_x: &'a f64,
	pub angular_velocity_offset_y: &'a f64,
	pub angular_velocity_offset_z: &'a f64,
	pub angular_velocity_stddev_xx: &'a f64,
	pub angular_velocity_stddev_yy: &'a f64,
	pub angular_velocity_stddev_zz: &'a f64,
	pub accel_stddev: &'a f64,
	pub var: TECSVarGuard<'a, TImuCorrectorVar>,
}

static IMUCORRECTOR: TImuCorrector<ETfForTTf> = TImuCorrector {
	c_tf: &ETFFORIMUCORRECTORTF,
	output_frame: "base_link",
	angular_velocity_offset_x: 0.0,
	angular_velocity_offset_y: 0.0,
	angular_velocity_offset_z: 0.0,
	angular_velocity_stddev_xx: 0.03,
	angular_velocity_stddev_yy: 0.03,
	angular_velocity_stddev_zz: 0.03,
	accel_stddev: 10000.0,
	variable: &IMUCORRECTORVAR,
};

static IMUCORRECTORVAR: TECSVariable<TImuCorrectorVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TImuCorrectorVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		linear_acceleration_covariance: nalgebra::Matrix3::default(),
		angular_velocity_covariance: nalgebra::Matrix3::default(),
	}
));
pub static EIMURAWFORIMUCORRECTOR: EImuRawForTImuCorrector = EImuRawForTImuCorrector {
	cell: &IMUCORRECTOR,
};

pub static EREACTORFORIMUCORRECTOR: EReactorForTImuCorrector = EReactorForTImuCorrector {
	cell: &IMUCORRECTOR,
};

impl<'a, T: STf> TImuCorrector<'a, T> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut awkernel_lib::sync::mutex::MCSNode<TImuCorrectorVar>) -> LockGuardForTImuCorrector<'_, T>
	where
		'b: 'a,
	{
		LockGuardForTImuCorrector {
			c_tf: self.c_tf,
			output_frame: &self.output_frame,
			angular_velocity_offset_x: &self.angular_velocity_offset_x,
			angular_velocity_offset_y: &self.angular_velocity_offset_y,
			angular_velocity_offset_z: &self.angular_velocity_offset_z,
			angular_velocity_stddev_xx: &self.angular_velocity_stddev_xx,
			angular_velocity_stddev_yy: &self.angular_velocity_stddev_yy,
			angular_velocity_stddev_zz: &self.angular_velocity_stddev_zz,
			accel_stddev: &self.accel_stddev,
			var: self.variable.lock(node),
		}
	}
}
