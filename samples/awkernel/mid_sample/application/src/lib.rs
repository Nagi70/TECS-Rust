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

use tecs_struct_def::*;

use tecs_celltype::t_dag_periodic_reactor::*;
use tecs_signature::s_periodic_reactorbody::*;

use tecs_celltype::t_dag_reactor::*;
use tecs_signature::s_reactorbody::*;

use tecs_celltype::t_dag_sink_reactor::*;
use tecs_signature::s_sink_reactorbody::*;

pub async fn run() {

	wait_microsec(1000000);

	let dag = create_dag();

	dag.register_periodic_reactor::<_, (Frame,)>(
		"dummy_imu".into(),
		|| -> (Frame,) {
			let mut imu: Frame = Default::default();
			DUMMYIMU.c_dag_periodic_reactorbody.main(&mut imu);
			(imu,)
		},
		vec![Cow::from("imu")],
		SchedulerType::PrioritizedFIFO(7),
		Duration::from_secs(1),
	)
	.await;

	dag.register_reactor::<_, (Frame,), (ImuMsg,)>(
		"imu_driver".into(),
		|(imu,): (Frame,)| -> (ImuMsg,) {
			let mut imu_raw: ImuMsg = Default::default();
			IMUDRIVER.c_dag_reactorbody.main(&imu, &mut imu_raw);
			(imu_raw,)
		},
		vec![Cow::from("imu")],
		vec![Cow::from("imu_raw")],
		SchedulerType::PrioritizedFIFO(7),
	)
	.await;

	dag.register_sink_reactor::<_, (ImuMsg,)>(
		"dummy_imu_corrector".into(),
		|(imu_raw,): (ImuMsg,)| {
			DUMMYIMUCORRECTOR.c_dag_sink_reactorbody.main(&imu_raw);
		},
		vec![Cow::from("imu_raw")],
		SchedulerType::PrioritizedFIFO(7),
		Duration::from_secs(1),
	)
	.await;

	let _ = finish_create_dags(&[dag.clone()]).await;
}
