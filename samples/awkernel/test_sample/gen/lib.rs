#![no_std]
#![feature(const_option)]
mod kernel_cfg;
mod tecs_ex_ctrl;
mod tecs_print;
mod t_reactor;
mod t_reactor_impl;
mod s_reactorbody;
mod s_pubsub;
mod s_task;
mod t_sink_reactor;
mod t_sink_reactor_impl;
mod s_sink_reactorbody;
mod t_periodic_reactor;
mod t_periodic_reactor_impl;
mod s_periodic_reactorbody;
mod t_imu;
mod t_imu_impl;
mod t_imu_corrector;
mod t_imu_corrector_impl;
mod t_gyro_odometer;
mod t_gyro_odometer_impl;

#[panic_handler]
fn panic(_panic: &core::panic::PanicInfo<'_>) -> ! {
    loop {}
}

use crate::t_reactor::*;
use s_task_body::*;

#[no_mangle]
pub extern "C" fn tecs_rust_start_reactor(_: usize) {
	REACTOR.c_task_body.main();
}

use crate::t_sink_reactor::*;

#[no_mangle]
pub extern "C" fn tecs_rust_start_sink_reactor(_: usize) {
	SINKREACTOR.c_task_body.main();
}

use crate::t_periodic_reactor::*;

#[no_mangle]
pub extern "C" fn tecs_rust_start_periodic_reactor(_: usize) {
	PERIODICREACTOR.c_task_body.main();
}
