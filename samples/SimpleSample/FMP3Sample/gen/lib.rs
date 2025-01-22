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
mod t_print;
mod t_print_impl;

#[panic_handler]
fn panic(_panic: &core::panic::PanicInfo<'_>) -> ! {
    loop {}
}

use crate::t_task_rs::*;
use s_task_body::*;

#[no_mangle]
pub extern "C" fn tecs_rust_start_r_processor1_symmetric__task1_1(_: usize) {
	RPROCESSOR1SYMMETRIC_TASK1_1.c_task_body.main();
}

#[no_mangle]
pub extern "C" fn tecs_rust_start_r_processor2_symmetric__task2_1(_: usize) {
	RPROCESSOR2SYMMETRIC_TASK2_1.c_task_body.main();
}
