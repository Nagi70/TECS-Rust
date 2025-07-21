pub trait SPubsub {
	fn send(&'static self);
	fn receive(&'static self);
}
