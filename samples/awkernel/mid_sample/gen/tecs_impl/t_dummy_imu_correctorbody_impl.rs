use crate::tecs_signature::t_dummy_imu_correctorbody::*;
use crate::tecs_signature::{s_imu_raw::*, s_dummy_imu_correctorbody::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SImuRaw for EImuRawForTDummyImuCorrectorbody<'_>{

}

impl SDummyImuCorrectorbody for EDummyImuCorrectorbodyForTDummyImuCorrectorbody<'_>{

	fn main(&'static self, imu_raw: &ImuMsg) {

	}
}

