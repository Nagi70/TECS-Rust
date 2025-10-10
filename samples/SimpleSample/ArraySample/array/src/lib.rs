#![no_std]
mod tecs_celltype;
mod tecs_signature;
mod tecs_impl;
mod tecs_global;
mod tecs_variable;
extern crate alloc;
use alloc::{borrow::Cow, vec};
use awkernel_async_lib::dag::{create_dag, finish_create_dags};
use awkernel_async_lib::scheduler::SchedulerType;
use awkernel_lib::delay::wait_microsec;
use core::time::Duration;

use tecs_global::*;

pub async fn run() {

	wait_microsec(1000000);

	let dag = create_dag();

	use tecs_signature::s_dummy::*;

	dag.register_sink_reactor::<_, (i32,)>(
		"Dummy".into(),
		|(value,): (i32,)| {
			tecs_celltype::t_dummy_dag_sink_reactor::DUMMYDAGSINKREACTOR.c_dag_sink_reactor.main(&value);
		},
		vec![Cow::from("Int")],
		SchedulerType::PrioritizedFIFO(7),
		Duration::from_secs(1),
	)
	.await;

	use tecs_signature::s_array_test::*;

	dag.register_periodic_reactor::<_, (i32,)>(
		"ArrayTest".into(),
		|| -> (i32,) {
			let mut value: i32 = Default::default();
			tecs_celltype::t_array_test_dag_periodic_reactor::ARRAYTESTDAGPERIODICREACTOR.c_dag_periodic_reactor.main(&mut value);
			(value,)
		},
		vec![Cow::from("Int")],
		SchedulerType::PrioritizedFIFO(7),
		Duration::from_millis(50),
	)
	.await;

	let _ = finish_create_dags(&[dag.clone()]).await;
}
