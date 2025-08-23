use crate::tecs_variable::*;
pub struct TTamagawaImuDevice{
	can_id_gyro: i32,
	can_id_accel: i32,
	imu_frame_id: str,
	variable: &'a TECSVariable<TTamagawaImuDevice>,
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
	pub cell: &'a TTamagawaImuDevice,
}

pub struct LockGuardForTTamagawaImuDevice<'a>{
	pub can_id_gyro: &'a i32,
	pub can_id_accel: &'a i32,
	pub imu_frame_id: &'a str,
	pub var: TECSVarGuard<'a, TTamagawaImuDevice>,
}

static CAN: TTamagawaImuDevice = TTamagawaImuDevice {
	can_id_gyro: 0x319,
	can_id_accel: 0x31A,
	imu_frame_id: "imu",
	variable: &CANVAR,
};

static CANVAR: TECSVariable<TTamagawaImuDevice> = TECSVariable::Raw(TECSSyncVar { unsafe_var: UnsafeCell::new(
	TTamagawaImuDevice {
/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.
		counter: 0,
		angular_velocity_x_raw: 0,
		angular_velocity_y_raw: 0,
		angular_velocity_z_raw: 0,
		acceleration_x_raw: 0,
		acceleration_y_raw: 0,
		acceleration_z_raw: 0,
	}),
});

pub static EIMUDEVICEFORCAN: EImuDeviceForTTamagawaImuDevice = EImuDeviceForTTamagawaImuDevice {
	cell: &CAN,
};

impl<> TTamagawaImuDevice {
	#[inline]
	pub fn get_cell_ref<'b>(&'a self, node: &'b mut MCSNode<TTamagawaImuDevice>) -> LockGuardForTTamagawaImuDevice
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
