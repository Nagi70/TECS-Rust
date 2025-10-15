
pub const IDX_X: u32 = 0;
pub const IDX_Y: u32 = 1;
pub const IDX_YAW: u32 = 2;
pub const IDX_YAWB: u32 = 3;
pub const IDX_VX: u32 = 4;
pub const IDX_WZ: u32 = 5;
pub const COV_IDX_X: u32 = 0;
pub const COV_IDX_Y: u32 = 1;
pub const COV_IDX_Z: u32 = 2;
pub const COV_IDX_ROLL: u32 = 3;
pub const COV_IDX_PITCH: u32 = 4;
pub const COV_IDX_YAW: u32 = 5;

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

impl Frame {
    pub const fn const_init() -> Self {
        Self {
            header: Header::const_init(),
            id: 0,
            is_rtr: false,
            is_extended: false,
            is_error: false,
            dlc: 0,
            data: [0; 8],
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

impl Header {
    pub const fn const_init() -> Self {
        Self {
            time_stamp: awkernel_lib::time::Time::zero(),
            frame_id: heapless::String::new(),
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

impl VelocityReport {
    pub const fn const_init() -> Self {
        Self {
            header: Header::const_init(),
            longitudinal_velocity: 0.0,
            lateral_velocity: 0.0,
            heading_rate: 0.0,
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

impl ImuMsg {
    pub const fn const_init() -> Self {
        Self {
            header: Header::const_init(),
            orientation: nalgebra::Quaternion::new(0.0, 0.0, 0.0, 0.0),
            orientation_covariance: nalgebra::Matrix3::new(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
            angular_velocity: nalgebra::Vector3::new(0.0, 0.0, 0.0),
            angular_velocity_covariance: nalgebra::Matrix3::new(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
            linear_acceleration: nalgebra::Vector3::new(0.0, 0.0, 0.0),
            linear_acceleration_covariance: nalgebra::Matrix3::new(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
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

impl TwistWithCovarianceStamped {
    pub const fn const_init() -> Self {
        Self {
            header: Header::const_init(),
            twist: TwistWithCovariance::const_init(),
        }
    }
}

#[derive(Clone)]
pub struct KinematicState {
    pub header: Header,
    pub child_frame_id: heapless::String<256>,
    pub pose: PoseWithCovariance,
    pub twist: TwistWithCovariance,
    pub accel: AccelWithCovariance,
}

impl Default for KinematicState {
	fn default() -> Self {
		Self {
			header: Default::default(),
			child_frame_id: Default::default(),
			pose: Default::default(),
			twist: Default::default(),
			accel: Default::default(),
		}
	}
}

impl KinematicState {
    pub const fn const_init() -> Self {
        Self {
            header: Header::const_init(),
            child_frame_id: heapless::String::new(),
            pose: PoseWithCovariance::const_init(),
            twist: TwistWithCovariance::const_init(),
            accel: AccelWithCovariance::const_init(),
        }
    }
}

#[derive(Clone)]
pub struct AccelWithCovarianceStamped {
    pub header: Header,
    pub accel: AccelWithCovariance,
}

impl Default for AccelWithCovarianceStamped {
	fn default() -> Self {
		Self {
			header: Default::default(),
			accel: Default::default(),
		}
	}
}

impl AccelWithCovarianceStamped {
    pub const fn const_init() -> Self {
        Self {
            header: Header::const_init(),
            accel: AccelWithCovariance::const_init(),
        }
    }
}

#[derive(Clone)]
pub struct Control {
    pub stamp: awkernel_lib::time::Time,
    pub lateral: Lateral,
    pub longitudinal: Longitudinal,
}

impl Default for Control {
	fn default() -> Self {
		Self {
			stamp: awkernel_lib::time::Time::zero(),
			lateral: Default::default(),
			longitudinal: Default::default(),
		}
	}
}

impl Control {
    pub const fn const_init() -> Self {
        Self {
            stamp: awkernel_lib::time::Time::zero(),
            lateral: Lateral::const_init(),
            longitudinal: Longitudinal::const_init(),
        }
    }
}

#[derive(Default, Clone)]
pub struct TwistWithCovariance {
    pub twist: Twist,
    pub covariance: nalgebra::Matrix6<f64>,
}

impl TwistWithCovariance {
    pub const fn const_init() -> Self {
        Self {
            twist: Twist::const_init(),
            covariance: nalgebra::Matrix6::new(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
        }
    }
}

#[derive(Default, Clone)]
pub struct Twist {
    pub linear: nalgebra::Vector3<f64>,
    pub angular: nalgebra::Vector3<f64>,
}

impl Twist {
    pub const fn const_init() -> Self {
        Self {
            linear: nalgebra::Vector3::new(0.0, 0.0, 0.0),
            angular: nalgebra::Vector3::new(0.0, 0.0, 0.0),
        }
    }
}

#[derive(Default, Clone)]
pub struct PoseWithCovariance {
    pub pose: Pose,
    pub covariance: nalgebra::Matrix6<f64>,
}

impl PoseWithCovariance {
    pub const fn const_init() -> Self {
        Self {
            pose: Pose::const_init(),
            covariance: nalgebra::Matrix6::new(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
        }
    }
}

#[derive(Default, Clone)]
pub struct Pose {
    pub point: nalgebra::Vector3<f64>,
    pub orientation: nalgebra::Quaternion<f64>,
}

impl Pose {
    pub const fn const_init() -> Self {
        Self {
            point: nalgebra::Vector3::new(0.0, 0.0, 0.0),
            orientation: nalgebra::Quaternion::new(0.0, 0.0, 0.0, 0.0),
        }
    }
}

#[derive(Default, Clone)]
pub struct AccelWithCovariance {
    pub accel: Accel,
    pub covariance: nalgebra::Matrix6<f64>,
}

impl AccelWithCovariance {
    pub const fn const_init() -> Self {
        Self {
            accel: Accel::const_init(),
            covariance: nalgebra::Matrix6::new(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
        }
    }
}

#[derive(Default, Clone)]
pub struct Accel {
    pub linear: nalgebra::Vector3<f64>,
    pub angular: nalgebra::Vector3<f64>,
}

impl Accel {
    pub const fn const_init() -> Self {
        Self {
            linear: nalgebra::Vector3::new(0.0, 0.0, 0.0),
            angular: nalgebra::Vector3::new(0.0, 0.0, 0.0),
        }
    }
}

#[derive(Clone)]
pub struct Lateral {
    pub stamp: awkernel_lib::time::Time,
    pub steering_tire_angle: f64,
}

impl Default for Lateral {
	fn default() -> Self {
		Self {
			stamp: awkernel_lib::time::Time::zero(),
			steering_tire_angle: Default::default(),
		}
	}
}

impl Lateral {
    pub const fn const_init() -> Self {
        Self {
            stamp: awkernel_lib::time::Time::zero(),
            steering_tire_angle: 0.0,
        }
    }
}

#[derive(Clone)]
pub struct Longitudinal {
    pub stamp: awkernel_lib::time::Time,
    pub velocity: f64,
    pub acceleration: f64,
}

impl Default for Longitudinal {
	fn default() -> Self {
		Self {
			stamp: awkernel_lib::time::Time::zero(),
			velocity: Default::default(),
			acceleration: Default::default(),
		}
	}
}

impl Longitudinal {
    pub const fn const_init() -> Self {
        Self {
            stamp: awkernel_lib::time::Time::zero(),
            velocity: 0.0,
            acceleration: 0.0,
        }
    }
}

#[derive(Default, Clone)]
pub struct Transform {
    pub translation: nalgebra::Vector3<f64>,
    pub rotatoin: nalgebra::Quaternion<f64>,
}

impl Transform {
    pub const fn const_init() -> Self {
        Self {
            translation: nalgebra::Vector3::new(0.0, 0.0, 0.0),
            rotatoin: nalgebra::Quaternion::new(0.0, 0.0, 0.0, 0.0),
        }
    }
}

#[derive(Default, Clone)]
pub struct Simple1DFilter {
    pub x: f64,
    pub value: f64,
}

impl Simple1DFilter {
    pub const fn const_init() -> Self {
        Self {
            x: 0.0,
            value: 0.0,
        }
    }
}

#[derive(Clone)]
pub struct PoseWithCovarianceStamped {
    pub header: Header,
    pub pose: PoseWithCovariance,
}

impl Default for PoseWithCovarianceStamped {
	fn default() -> Self {
		Self {
			header: Default::default(),
			pose: Default::default(),
		}
	}
}

impl PoseWithCovarianceStamped {
    pub const fn const_init() -> Self {
        Self {
            header: Header::const_init(),
            pose: PoseWithCovariance::const_init(),
        }
    }
}

#[derive(Clone)]
pub struct TwistStamped {
    pub header: Header,
    pub twist: Twist,
}

impl Default for TwistStamped {
	fn default() -> Self {
		Self {
			header: Default::default(),
			twist: Default::default(),
		}
	}
}

impl TwistStamped {
    pub const fn const_init() -> Self {
        Self {
            header: Header::const_init(),
            twist: Twist::const_init(),
        }
    }
}

