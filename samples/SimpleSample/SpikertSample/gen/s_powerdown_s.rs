use spin::Mutex;
pub trait SPowerdownS {
	fn powerdown<'a>(&self, ult: &Option<&'a mut pup_ultrasonic_sensor_t>);
}
