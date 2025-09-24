use crate::tecs_variable::*;
pub struct TTamagawaImuDevice<'a>{
	can_id_gyro: u32,
	can_id_accel: u32,
	imu_frame_id: &'static str,
	variable: &'a TECSVariable<TTamagawaImuDeviceVar>,
}

pub struct TTamagawaImuDeviceVar{
	pub counter: u16,
	pub angular_velocity_x_raw: i16,
	pub angular_velocity_y_raw: i16,
	pub angular_velocity_z_raw: i16,
	pub acceleration_x_raw: i16,
	pub acceleration_y_raw: i16,
	pub acceleration_z_raw: i16,
}

pub struct EImuDeviceForTTamagawaImuDevice<'a>{
	pub cell: &'a TTamagawaImuDevice<'a>,
}

pub struct LockGuardForTTamagawaImuDevice<'a>{
	pub can_id_gyro: &'a u32,
	pub can_id_accel: &'a u32,
	pub imu_frame_id: &'a &'static str,
	pub var: TECSVarGuard<'a, TTamagawaImuDeviceVar>,
}

static TAMAGAWACAN: TTamagawaImuDevice = TTamagawaImuDevice {
	can_id_gyro: 0x319,
	can_id_accel: 0x31A,
	imu_frame_id: "imu",
	variable: &TAMAGAWACANVAR,
};

static TAMAGAWACANVAR: TECSVariable<TTamagawaImuDeviceVar> = TECSVariable::Mutexed(awkernel_lib::sync::mutex::Mutex::new(
	TTamagawaImuDeviceVar {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		counter: 0,
		angular_velocity_x_raw: 0,
		angular_velocity_y_raw: 0,
		angular_velocity_z_raw: 0,
		acceleration_x_raw: 0,
		acceleration_y_raw: 0,
		acceleration_z_raw: 0,
	}
));
pub static EIMUDEVICEFORTAMAGAWACAN: EImuDeviceForTTamagawaImuDevice = EImuDeviceForTTamagawaImuDevice {
	cell: &TAMAGAWACAN,
};

impl<'a> TTamagawaImuDevice<'a> {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut awkernel_lib::sync::mutex::MCSNode<TTamagawaImuDeviceVar>) -> LockGuardForTTamagawaImuDevice<'_>
	where
		'b: 'a,
	{
		LockGuardForTTamagawaImuDevice {
			can_id_gyro: &self.can_id_gyro,
			can_id_accel: &self.can_id_accel,
			imu_frame_id: &self.imu_frame_id,
			var: self.variable.lock(node),
		}
	}
}
