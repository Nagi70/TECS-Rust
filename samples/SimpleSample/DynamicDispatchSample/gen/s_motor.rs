use spin::Mutex;
pub trait SMotor {
	fn set_motor_ref(&self);
	fn setup(&self, positive_direction: &pup_direction_t, reset_count: &bool);
	fn set_speed(&self, speed: &i32);
	fn stop(&self);
}
