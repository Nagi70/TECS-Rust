#![no_std]
mod tecs_celltype;
mod tecs_signature;
mod tecs_impl;
mod tecs_struct_def;
mod tecs_variable;
extern crate alloc;
use alloc::{borrow::Cow, vec};
use awkernel_async_lib::dag::{create_dag, finish_create_dags};
use awkernel_async_lib::scheduler::SchedulerType;
use awkernel_lib::delay::wait_microsec;
use core::time::Duration;

use tecs_struct_def::*;

use tecs_celltype::t_dag_periodic_reactor::*;
use tecs_celltype::t_dag_reactor::*;
use tecs_celltype::t_dag_sink_reactor::*;
use tecs_signature::s_reactorbody::*;

pub async fn run() {

	wait_microsec(1000000);

	let dag = create_dag();

use tecs_signature::s_imudriverbody::*;

	dag.register_reactor::<_, (ImuMsg,), (ImuMsg,)>(
		"ImuDriver".into(),
		|(imu,): (ImuMsg,)| -> (ImuMsg,) {
			let mut imu_raw: ImuMsg = Default::default();
			tecs_celltype::t_imu_driverbody_dag_reactor::IMUDRIVERBODYDAGREACTOR.c_dag_reactor.main(&imu, &mut imu_raw);
			(imu_raw,)
		},
		vec![Cow::from("Imu")],
		vec![Cow::from("ImuRaw")],
		SchedulerType::FIFO,
	)
	.await;

use tecs_signature::s_dummy_imu_correctorbody::*;

	dag.register_sink_reactor::<_, (ImuMsg,)>(
		"DummyImuCorrector".into(),
		|(imu_raw,): (ImuMsg,)| {
			tecs_celltype::t_dummy_imu_correctorbody_dag_sink_reactor::DUMMYIMUCORRECTORBODYDAGSINKREACTOR.c_dag_sink_reactor.main(&imu_raw);
		},
		vec![Cow::from("ImuRaw")],
		SchedulerType::FIFO,
		Duration::from_secs(1),
	)
	.await;

use tecs_signature::s_dummy_imubody::*;

	dag.register_periodic_reactor::<_, (ImuMsg,)>(
		"DummyImu".into(),
		|| -> (ImuMsg,) {
			let mut imu: ImuMsg = Default::default();
			tecs_celltype::t_dummy_imubody_dag_periodic_reactor::DUMMYIMUBODYDAGPERIODICREACTOR.c_dag_periodic_reactor.main(&mut imu);
			(imu,)
		},
		vec![Cow::from("Imu")],
		SchedulerType::FIFO,
		Duration::from_millis(50),
	)
	.await;

	let _ = finish_create_dags(&[dag.clone()]).await;
}
