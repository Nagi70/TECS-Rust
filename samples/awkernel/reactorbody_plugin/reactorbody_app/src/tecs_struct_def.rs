use awkernel_lib::time::Time;
#[derive(Clone)]
pub struct ImuMsg {
    pub header: Header,
    pub orientation: Quaternion,
    pub orientation_covariance: [f64; 9],
    pub angular_velocity: Vector3,
    pub angular_velocity_covariance: [f64; 9],
    pub linear_acceleration: Vector3,
    pub linear_acceleration_covariance: [f64; 9],
}

impl Default for ImuMsg {
	fn default() -> Self {
		Self {
			header: Default::default(),
			orientation: Default::default(),
			orientation_covariance: Default::default(),
			angular_velocity: Default::default(),
			angular_velocity_covariance: Default::default(),
			linear_acceleration: Default::default(),
			linear_acceleration_covariance: Default::default(),
		}
	}
}

#[derive(Clone)]
pub struct Header {
    pub time_stamp: Time,
    pub frame_id: heapless::String<256>,
}

impl Default for Header {
	fn default() -> Self {
		Self {
			time_stamp: Time::zero(),
			frame_id: Default::default(),
		}
	}
}

#[derive(Default, Clone)]
pub struct Quaternion {
    pub x: f64,
    pub y: f64,
    pub z: f64,
    pub w: f64,
}

#[derive(Default, Clone)]
pub struct Vector3 {
    pub x: f64,
    pub y: f64,
    pub z: f64,
}

