use spin::Mutex;
use itron::abi::*;
use itron::unknown::unknown;
pub trait SSensor {
	fn set_device_ref(&'static self);
	fn get_distance(&'static self, distance: &mut i32);
	fn light_on(&'static self);
	fn light_set(&'static self, bv1: &i32, bv2: &i32, bv3: &i32, bv4: &i32);
	fn light_off(&'static self);
}
