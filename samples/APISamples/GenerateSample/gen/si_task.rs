pub trait SiTask {
	fn activate(&'static self)-> ER;
	fn wakeup(&'static self)-> ER;
	fn release_wait(&'static self)-> ER;
}
