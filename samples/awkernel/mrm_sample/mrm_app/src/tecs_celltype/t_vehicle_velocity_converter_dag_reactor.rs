use crate::tecs_signature::s_vehicle_velocity_converter::*;
use crate::tecs_celltype::t_vehicle_velocity_converter::*;
pub struct TVehicleVelocityConverterDagReactor<T>
where
	T: SVehicleVelocityConverter + 'static,
{
	pub c_dag_reactor: &'static T,
}

pub struct LockGuardForTVehicleVelocityConverterDagReactor<'a, T>
where
	T: SVehicleVelocityConverter + 'static,
{
	pub c_dag_reactor: &'a T,
}

pub static VEHICLEVELOCITYCONVERTERDAGREACTOR: TVehicleVelocityConverterDagReactor<EReactorForTVehicleVelocityConverter> = TVehicleVelocityConverterDagReactor {
	c_dag_reactor: &EREACTORFORVEHICLEVELOCITYCONVERTER,
};

