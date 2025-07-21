#![no_std]
#![feature(const_option)]
mod kernel_cfg;
mod tecs_ex_ctrl;
mod tecs_print;
mod tecs_celltype;
mod tecs_signature;
mod tecs_impl;

#[panic_handler]
fn panic(_panic: &core::panic::PanicInfo<'_>) -> ! {
	loop {}
}

use tecs_celltype::t_reactor::*;
use tecs_celltype::t_sink_reactor::*;
use tecs_celltype::t_periodic_reactor::*;
use tecs_signature::s_task_body::*;

#[no_mangle]
pub extern "C" fn tecs_rust_start_reactor(_: usize) {
	REACTOR.c_task_body.main();
}

#[no_mangle]
pub extern "C" fn tecs_rust_start_sink_reactor(_: usize) {
	SINKREACTOR.c_task_body.main();
}

#[no_mangle]
pub extern "C" fn tecs_rust_start_periodic_reactor(_: usize) {
	PERIODICREACTOR.c_task_body.main();
}
