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

	use tecs_signature::s_stop_filter::*;

	spawn_reactor::<_, (KinematicState,), (KinematicState,)>(
		"StopFilter".into(),
		|(odom_in,): (KinematicState,)| -> (KinematicState,) {
			let mut odom_out: KinematicState = Default::default();
			tecs_celltype::t_stop_filter_reactor::STOPFILTERREACTOR.c_reactor.main(&odom_in, &mut odom_out);
			(odom_out,)
		},
		vec![Cow::from("KinematicState")],
		vec![Cow::from("KinematicStateSf")],
		SchedulerType::FIFO,
	)
	.await;

	use tecs_signature::s_twist2_accel::*;

	spawn_reactor::<_, (KinematicState,), (AccelWithCovarianceStamped,)>(
		"Twist2Accel".into(),
		|(twist,): (KinematicState,)| -> (AccelWithCovarianceStamped,) {
			let mut accel: AccelWithCovarianceStamped = Default::default();
			tecs_celltype::t_twist2_accel_reactor::TWIST2ACCELREACTOR.c_reactor.main(&twist, &mut accel);
			(accel,)
		},
		vec![Cow::from("KinematicState")],
		vec![Cow::from("Accel")],
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

	use tecs_signature::s_trajectory_follower::*;

	spawn_sink_reactor::<_, (KinematicState,AccelWithCovarianceStamped,)>(
		"TrajectoryFollower".into(),
		|(kinematic_state,accel,): (KinematicState,AccelWithCovarianceStamped,)| {
			tecs_celltype::t_trajectory_follower_sink_reactor::TRAJECTORYFOLLOWERSINKREACTOR.c_sink_reactor.main(&kinematic_state, &accel);
		},
		vec![Cow::from("KinematicStateSf, Accel")],
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

	use tecs_signature::s_ekf_localizer_timer::*;

	spawn_periodic_reactor::<_, (KinematicState,)>(
		"EkfLocalizerTimer".into(),
		|| -> (KinematicState,) {
			let mut kinematic_state: KinematicState = Default::default();
			tecs_celltype::t_ekf_localizer_timer_periodic_reactor::EKFLOCALIZERTIMERPERIODICREACTOR.c_periodic_reactor.main(&mut kinematic_state);
			(kinematic_state,)
		},
		vec![Cow::from("KinematicState")],
		SchedulerType::FIFO,
		Duration::from_millis(50),
	)
	.await;

	let _ = finish_create_dags(&[dag.clone()]).await;
}
