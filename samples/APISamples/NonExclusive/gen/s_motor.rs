use spin::Mutex;
pub trait SMotor {
	fn set_motor_ref(&'static self);
	fn setup(&'static self, positive_direction: &pbio_direction_t, reset_count: &bool);
	fn set_speed(&'static self, speed: &i32);
	fn stop(&'static self);
}
