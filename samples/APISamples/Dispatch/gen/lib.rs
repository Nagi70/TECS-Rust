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
mod t_motorbody;
mod t_motorbody_impl;
mod t_sensorbody;
mod t_sensorbody_impl;
mod t_mmbody;
mod t_mmbody_impl;
mod t_ssbody;
mod t_ssbody_impl;

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

#[no_mangle]
pub extern "C" fn tecs_rust_start_task3(_: usize) {
	TASK3.c_task_body.main();
}

#[no_mangle]
pub extern "C" fn tecs_rust_start_task4(_: usize) {
	TASK4.c_task_body.main();
}
