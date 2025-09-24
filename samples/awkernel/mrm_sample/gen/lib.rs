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

pub async fn run() {

	wait_microsec(1000000);

	let dag = create_dag();

	use tecs_signature::s_imu_driver::*;

	spawn_reactor::<_, (Frame,), (ImuMsg,)>(
		"ImuDriver".into(),
		|(imu,): (Frame,)| -> (ImuMsg,) {
			let mut imu_raw: ImuMsg = Default::default();
			tecs_celltype::t_imu_driver_reactor::IMUDRIVERREACTOR.c_reactor.main(&imu, &mut imu_raw);
			(imu_raw,)
		},
		vec![Cow::from("Imu")],
		vec![Cow::from("ImuRaw")],
		SchedulerType::FIFO,
	)
	.await;

	use tecs_signature::s_imu_corrector::*;

	spawn_reactor::<_, (ImuMsg,), (ImuMsg,)>(
		"ImuCorrector".into(),
		|(imu_raw,): (ImuMsg,)| -> (ImuMsg,) {
			let mut imu_data: ImuMsg = Default::default();
			tecs_celltype::t_imu_corrector_reactor::IMUCORRECTORREACTOR.c_reactor.main(&imu_raw, &mut imu_data);
			(imu_data,)
		},
		vec![Cow::from("ImuRaw")],
		vec![Cow::from("ImuData")],
		SchedulerType::FIFO,
	)
	.await;

	use tecs_signature::s_vehicle_velocity_converter::*;

	spawn_reactor::<_, (VelocityReport,), (TwistWithCovarianceStamped,)>(
		"VehicleVelocityConverter".into(),
		|(velocity_status,): (VelocityReport,)| -> (TwistWithCovarianceStamped,) {
			let mut twist_with_covariance: TwistWithCovarianceStamped = Default::default();
			tecs_celltype::t_vehicle_velocity_converter_reactor::VEHICLEVELOCITYCONVERTERREACTOR.c_reactor.main(&velocity_status, &mut twist_with_covariance);
			(twist_with_covariance,)
		},
		vec![Cow::from("VelocityStatus")],
		vec![Cow::from("TwistWithCovarianceV")],
		SchedulerType::FIFO,
	)
	.await;

	use tecs_signature::s_gyro_odometer::*;

	spawn_reactor::<_, (TwistWithCovarianceStamped,ImuMsg,), (TwistWithCovarianceStamped,)>(
		"GyroOdometer".into(),
		|(vehicle_twist,imu,): (TwistWithCovarianceStamped,ImuMsg,)| -> (TwistWithCovarianceStamped,) {
			let mut twist_with_covariance: TwistWithCovarianceStamped = Default::default();
			tecs_celltype::t_gyro_odometer_reactor::GYROODOMETERREACTOR.c_reactor.main(&vehicle_twist, &imu, &mut twist_with_covariance);
			(twist_with_covariance,)
		},
		vec![Cow::from("TwistWithCovarianceV, ImuData")],
		vec![Cow::from("TwistWithCovarianceG")],
		SchedulerType::FIFO,
	)
	.await;

	use tecs_signature::s_ekf_localizer::*;

	spawn_sink_reactor::<_, (TwistWithCovarianceStamped,)>(
		"EkfLocalizer".into(),
		|(twist,): (TwistWithCovarianceStamped,)| {
			tecs_celltype::t_ekf_localizer_sink_reactor::EKFLOCALIZERSINKREACTOR.c_sink_reactor.main(&twist);
		},
		vec![Cow::from("TwistWithCovarianceG")],
		SchedulerType::FIFO,
		Duration::from_secs(1),
	)
	.await;

	use tecs_signature::s_dummy_periodic_reactor_in_mrm::*;

	spawn_periodic_reactor::<_, (Frame,VelocityReport,)>(
		"DummyPeriodicReactorInMrm".into(),
		|| -> (Frame,VelocityReport,) {
			let mut imu: Frame = Default::default();
			let mut velocity_status: VelocityReport = Default::default();
			tecs_celltype::t_dummy_periodic_reactor_in_mrm_periodic_reactor::DUMMYHARDWAREPERIODICREACTOR.c_periodic_reactor.main(&mut imu, &mut velocity_status);
			(imu,velocity_status,)
		},
		vec![Cow::from("Imu, VelocityStatus")],
		SchedulerType::FIFO,
		Duration::from_millis(50),
	)
	.await;

	let _ = finish_create_dags(&[dag.clone()]).await;
}
