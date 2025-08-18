use awkernel_lib::time::Time;
pub struct Frame {
    pub header: Header,
    pub id: u32,
    pub is_rtr: bool,
    pub is_extended: bool,
    pub is_error: bool,
    pub dlc: u8,
    pub data: [u8; 8],
}

impl Default for Frame {
	fn default() -> Self {
		Self {
			header: Default::default(),
			id: Default::default(),
			is_rtr: Default::default(),
			is_extended: Default::default(),
			is_error: Default::default(),
			dlc: Default::default(),
			data: Default::default(),
		}
	}
}

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

#[derive(Default)]
pub struct Quaternion {
    pub x: f64,
    pub y: f64,
    pub z: f64,
    pub w: f64,
}

#[derive(Default)]
pub struct Vector3 {
    pub x: f64,
    pub y: f64,
    pub z: f64,
}

