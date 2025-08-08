pub trait SImuDriverbody {
	fn main(&'static self, imu: &ImuMsg, imu_raw: &mut ImuMsg);
}
