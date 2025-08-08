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

use tecs_celltype::t_dag_periodic_reactor::*;
use tecs_signature::s_periodic_reactorbody::*;

use tecs_celltype::t_dag_reactor::*;
use tecs_signature::s_reactorbody::*;

use tecs_celltype::t_dag_sink_reactor::*;
use tecs_signature::s_sink_reactorbody::*;

pub async fn run() {

	wait_microsec(1000000);

	let dag = create_dag();

	dag.register_periodic_reactor::<_, (ImuMsg,)>(
		"dummy_imu".into(),
		|| -> (ImuMsg,)> {
			let mut imu = ImuMsg;
			DUMMYIMU.c_periodic_reactorbody.main(&mut imu);
			(imu,)
		},
		vec![Cow::from("imu")],
		SchedulerType::SchedulerType::FIFO,
		Duration::from_sec(1),
	)
	.await;

	dag.register_reactor::<_, (ImuMsg,), (ImuMsg,)>(
		"imu_driver".into(),
		|(imu,): (ImuMsg,)| -> (ImuMsg,)> {
			let mut imu_raw = ImuMsg;
			IMUDRIVER.c_reactorbody.main(&imu,,&mut imu_raw);
			(imu_raw,)
		},
		vec![Cow::from("imu")],
		vec![Cow::from("imu_raw")],
		SchedulerType::SchedulerType::FIFO,
	)
	.await;

	dag.register_sink_reactor::<_, (ImuMsg,)>(
		"imu_corrector".into(),
		|(imu_raw,): (ImuMsg,)| {
			DUMMYIMUCORRECTOR.c_sink_reactorbody.main(&imu_raw,);
		},
		vec![Cow::from("imu_raw")],
		SchedulerType::SchedulerType::FIFO,
		Duration::from_sec(1),
	)
	.await;

	let _ = finish_create_dags(&[dag.clone()]).await;
}
