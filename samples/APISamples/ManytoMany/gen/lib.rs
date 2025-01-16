#![no_std]
#![feature(const_option)]
mod kernel_cfg;
mod tecs_ex_ctrl;
mod tecs_print;
mod t_task_rs;
mod t_task_rs_impl;
mod s_task;
mod si_task;
mod s_task_body;
mod si_notification_handler;
mod t_sensor_a;
mod t_sensor_a_impl;
mod s_sensor;
mod t_sensor_b;
mod t_sensor_b_impl;
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

#[no_mangle]
pub extern "C" fn tecs_rust_start_task2(_: usize) {
	TASK2.c_task_body.main();
}
