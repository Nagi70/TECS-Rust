use crate::tecs_signature::s_vehicle_velocity_converter::*;
use crate::tecs_celltype::t_vehicle_velocity_converter::*;
pub struct TVehicleVelocityConverterReactor<'a, T>
where
	T: SVehicleVelocityConverter,
{
	pub c_reactor: &'a T,
}

pub struct LockGuardForTVehicleVelocityConverterReactor<'a, T>
where
	T: SVehicleVelocityConverter,
{
	pub c_reactor: &'a T,
}

pub static VEHICLEVELOCITYCONVERTERREACTOR: TVehicleVelocityConverterReactor<EReactorForTVehicleVelocityConverter> = TVehicleVelocityConverterReactor {
	c_reactor: &EREACTORFORVEHICLEVELOCITYCONVERTER,
};

