#![no_std]
mod tecs_celltype;
mod tecs_signature;
mod tecs_impl;
extern crate alloc;
use alloc::{borrow::Cow, vec};
use awkernel_async_lib::dag::{create_dag, finish_create_dags};
use awkernel_async_lib::scheduler::SchedulerType;
use awkernel_lib::delay::wait_microsec;
use core::time::Duration;

use tecs_celltype::t_periodic_reactor::*;
use tecs_signature::s_periodic_reactorbody::*;

use tecs_celltype::t_sink_reactor::*;
use tecs_signature::s_sink_reactorbody::*;

pub async fn run() {

	wait_microsec(1000000);

	let dag = create_dag();

	dag.register_periodic_reactor::<_, (Test,)>(
		"periodic_reactor".into(),
		|| -> (Test,)> {
			let mut camera_info = Test;
			CAMERABODY.c_periodic_reactorbody.main(&mut camera_info);
			(camera_info,)
		},
		vec![Cow::from("CameraInfo")],
		SchedulerType::FIFO,
		Duration::from_sec(1),
	)
	.await;

	dag.register_sink_reactor::<_, (Test,)>(
		"sink_reactor".into(),
		|(camera_info,): (Test,)| {
			BEVBODY.c_sink_reactorbody.main(&camera_info,);
		},
		vec![Cow::from("CameraInfo")],
		SchedulerType::FIFO,
		Duration::from_sec(1),
	)
	.await;

	let _ = finish_create_dags(&[dag.clone()]).await;
}
