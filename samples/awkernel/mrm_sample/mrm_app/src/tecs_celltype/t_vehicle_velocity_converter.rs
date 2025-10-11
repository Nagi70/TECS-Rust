use crate::tecs_global::*;
use crate::tecs_signature::s_twist_with_covariance_stamped::*;
use crate::tecs_celltype::t_gyro_odometer::*;
pub struct TVehicleVelocityConverter{
	frame_id: &'static str,
	velocity_stddev_xx: f64,
	angular_velocity_stddev_zz: f64,
	speed_scale_factor: f64,
}

pub struct EVelocityStatusForTVehicleVelocityConverter {
	pub cell: &'static TVehicleVelocityConverterstatic VEHICLEVELOCITYCONVERTER: TVehicleVelocityConverter = TVehicleVelocityConverter {
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

