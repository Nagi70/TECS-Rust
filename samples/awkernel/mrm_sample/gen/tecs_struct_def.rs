use awkernel_lib::time::Time;
#[derive(Clone)]
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

#[derive(Clone)]
pub struct Header {
    pub time_stamp: awkernel_lib::time::Time,
    pub frame_id: heapless::String<256>,
}

impl Default for Header {
	fn default() -> Self {
		Self {
			time_stamp: awkernel_lib::time::Time::zero(),
			frame_id: Default::default(),
		}
	}
}

#[derive(Clone)]
pub struct VelocityReport {
    pub header: Header,
    pub longitudinal_velocity: f32,
    pub lateral_velocity: f32,
    pub heading_rate: f32,
}

impl Default for VelocityReport {
	fn default() -> Self {
		Self {
			header: Default::default(),
			longitudinal_velocity: Default::default(),
			lateral_velocity: Default::default(),
			heading_rate: Default::default(),
		}
	}
}

#[derive(Clone)]
pub struct ImuMsg {
    pub header: Header,
    pub orientation: nalgebra::Quaternion<f64>,
    pub orientation_covariance: nalgebra::Matrix3<f64>,
    pub angular_velocity: nalgebra::Vector3<f64>,
    pub angular_velocity_covariance: nalgebra::Matrix3<f64>,
    pub linear_acceleration: nalgebra::Vector3<f64>,
    pub linear_acceleration_covariance: nalgebra::Matrix3<f64>,
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
pub struct TwistWithCovarianceStamped {
    pub header: Header,
    pub twist: TwistWithCovariance,
}

impl Default for TwistWithCovarianceStamped {
	fn default() -> Self {
		Self {
			header: Default::default(),
			twist: Default::default(),
		}
	}
}

#[derive(Default, Clone)]
pub struct TwistWithCovariance {
    pub twist: Twist,
    pub covariance: nalgebra::Matrix6<f64>,
}

#[derive(Default, Clone)]
pub struct Twist {
    pub linear: nalgebra::Vector3<f64>,
    pub angular: nalgebra::Vector3<f64>,
}

