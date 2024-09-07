use spin::Mutex;
pub trait SPowerdownM {
	fn powerdown<'a>(&self, motor: &Option<&'a mut pup_motor_t>);
}
