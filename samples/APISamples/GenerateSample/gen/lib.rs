#![no_std]
#![feature(const_option)]
mod kernel_cfg;
mod tecs_mutex;
mod tecs_print;
mod t_task_rs;
mod t_task_rs_impl;
mod s_task;
mod si_task;
mod s_task_body;
mod si_notification_handler;
mod t_motor;
mod t_motor_impl;
mod s_motor;
mod t_sensor;
mod t_sensor_impl;
mod s_sensor;
mod t_taskbody;
mod t_taskbody_impl;

#[panic_handler]
fn panic(_panic: &core::panic::PanicInfo<'_>) -> ! {
    loop {}
}

use crate::t_task_rs::*;
use s_task_body::*;

#[no_mangle]
pub extern "C" fn tecs_rust_start_task1(_: usize) {
	TASK1.c_task_body.main();
}
