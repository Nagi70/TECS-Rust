use crate::tecs_global::*;
use crate::tecs_signature::s_twist_with_covariance_stamped::*;
use crate::tecs_celltype::t_gyro_odometer::*;
pub struct TVehicleVelocityConverter<'a>{
	frame_id: &'static str,
	velocity_stddev_xx: f64,
	angular_velocity_stddev_zz: f64,
	speed_scale_factor: f64,
}

pub struct EVelocityStatusForTVehicleVelocityConverter<'a>{
	pub cell: &'a TVehicleVelocityConverter<'a>,
}

pub struct EReactorForTVehicleVelocityConverter<'a>{
	pub cell: &'a TVehicleVelocityConverter<'a>,
}

pub struct LockGuardForTVehicleVelocityConverter<'a>{
	pub frame_id: &'a &'static str,
	pub velocity_stddev_xx: &'a f64,
	pub angular_velocity_stddev_zz: &'a f64,
	pub speed_scale_factor: &'a f64,
}

static VEHICLEVELOCITYCONVERTER: TVehicleVelocityConverter = TVehicleVelocityConverter {
	frame_id: "base_link",
	velocity_stddev_xx: 0.2,
	angular_velocity_stddev_zz: 0.1,
	speed_scale_factor: 1.0,
};

pub static EVELOCITYSTATUSFORVEHICLEVELOCITYCONVERTER: EVelocityStatusForTVehicleVelocityConverter = EVelocityStatusForTVehicleVelocityConverter {
	cell: &VEHICLEVELOCITYCONVERTER,
};

pub static EREACTORFORVEHICLEVELOCITYCONVERTER: EReactorForTVehicleVelocityConverter = EReactorForTVehicleVelocityConverter {
	cell: &VEHICLEVELOCITYCONVERTER,
};

impl<'a> TVehicleVelocityConverter<'a> {
	#[inline]
	pub fn get_cell_ref(&'a self) -> LockGuardForTVehicleVelocityConverter<'_>	{
		LockGuardForTVehicleVelocityConverter {
			frame_id: &self.frame_id,
			velocity_stddev_xx: &self.velocity_stddev_xx,
			angular_velocity_stddev_zz: &self.angular_velocity_stddev_zz,
			speed_scale_factor: &self.speed_scale_factor,
		}
	}
}
