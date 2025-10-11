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

	dag.register_reactor::<_, (Frame,), (ImuMsg,)>(
		"ImuDriver".into(),
		|(imu,): (Frame,)| -> (ImuMsg,) {
			let mut imu_raw: ImuMsg = Default::default();
			tecs_celltype::t_imu_driver_dag_reactor::IMUDRIVERDAGREACTOR.c_dag_reactor.main(&imu, &mut imu_raw);
			(imu_raw,)
		},
		vec![Cow::from("Imu")],
		vec![Cow::from("ImuRaw")],
		SchedulerType::PrioritizedFIFO(7),
	)
	.await;

	use tecs_signature::s_imu_corrector::*;

	dag.register_reactor::<_, (ImuMsg,), (ImuMsg,)>(
		"ImuCorrector".into(),
		|(imu_raw,): (ImuMsg,)| -> (ImuMsg,) {
			let mut imu_data: ImuMsg = Default::default();
			tecs_celltype::t_imu_corrector_dag_reactor::IMUCORRECTORDAGREACTOR.c_dag_reactor.main(&imu_raw, &mut imu_data);
			(imu_data,)
		},
		vec![Cow::from("ImuRaw")],
		vec![Cow::from("ImuData")],
		SchedulerType::PrioritizedFIFO(7),
	)
	.await;

	use tecs_signature::s_vehicle_velocity_converter::*;

	dag.register_reactor::<_, (VelocityReport,), (TwistWithCovarianceStamped,)>(
		"VehicleVelocityConverter".into(),
		|(velocity_status,): (VelocityReport,)| -> (TwistWithCovarianceStamped,) {
			let mut twist_with_covariance: TwistWithCovarianceStamped = Default::default();
			tecs_celltype::t_vehicle_velocity_converter_dag_reactor::VEHICLEVELOCITYCONVERTERDAGREACTOR.c_dag_reactor.main(&velocity_status, &mut twist_with_covariance);
			(twist_with_covariance,)
		},
		vec![Cow::from("VelocityStatus")],
		vec![Cow::from("TwistWithCovarianceV")],
		SchedulerType::PrioritizedFIFO(7),
	)
	.await;

	use tecs_signature::s_gyro_odometer::*;

	dag.register_reactor::<_, (TwistWithCovarianceStamped,ImuMsg,), (TwistWithCovarianceStamped,)>(
		"GyroOdometer".into(),
		|(vehicle_twist,imu,): (TwistWithCovarianceStamped,ImuMsg,)| -> (TwistWithCovarianceStamped,) {
			let mut twist_with_covariance: TwistWithCovarianceStamped = Default::default();
			tecs_celltype::t_gyro_odometer_dag_reactor::GYROODOMETERDAGREACTOR.c_dag_reactor.main(&vehicle_twist, &imu, &mut twist_with_covariance);
			(twist_with_covariance,)
		},
		vec![Cow::from("TwistWithCovarianceV, ImuData")],
		vec![Cow::from("TwistWithCovarianceG")],
		SchedulerType::PrioritizedFIFO(7),
	)
	.await;

	use tecs_signature::s_stop_filter::*;

	dag.register_reactor::<_, (KinematicState,), (KinematicState,)>(
		"StopFilter".into(),
		|(odom_in,): (KinematicState,)| -> (KinematicState,) {
			let mut odom_out: KinematicState = Default::default();
			tecs_celltype::t_stop_filter_dag_reactor::STOPFILTERDAGREACTOR.c_dag_reactor.main(&odom_in, &mut odom_out);
			(odom_out,)
		},
		vec![Cow::from("KinematicState")],
		vec![Cow::from("KinematicStateSf")],
		SchedulerType::PrioritizedFIFO(7),
	)
	.await;

	use tecs_signature::s_twist2_accel::*;

	dag.register_reactor::<_, (KinematicState,), (AccelWithCovarianceStamped,)>(
		"Twist2Accel".into(),
		|(twist,): (KinematicState,)| -> (AccelWithCovarianceStamped,) {
			let mut accel: AccelWithCovarianceStamped = Default::default();
			tecs_celltype::t_twist2_accel_dag_reactor::TWIST2ACCELDAGREACTOR.c_dag_reactor.main(&twist, &mut accel);
			(accel,)
		},
		vec![Cow::from("KinematicState")],
		vec![Cow::from("Accel")],
		SchedulerType::PrioritizedFIFO(7),
	)
	.await;

	use tecs_signature::s_trajectory_follower::*;

	dag.register_reactor::<_, (KinematicState,AccelWithCovarianceStamped,), (Control,)>(
		"TrajectoryFollower".into(),
		|(kinematic_state,accel,): (KinematicState,AccelWithCovarianceStamped,)| -> (Control,) {
			let mut control: Control = Default::default();
			tecs_celltype::t_trajectory_follower_dag_reactor::TRAJECTORYFOLLOWERDAGREACTOR.c_dag_reactor.main(&kinematic_state, &accel, &mut control);
			(control,)
		},
		vec![Cow::from("KinematicStateSf, Accel")],
		vec![Cow::from("Control")],
		SchedulerType::PrioritizedFIFO(7),
	)
	.await;

	use tecs_signature::s_dummy_sink_reactor_in_mrm::*;

	dag.register_sink_reactor::<_, (Control,)>(
		"DummyPeriodicReactorInMrm".into(),
		|(control,): (Control,)| {
			tecs_celltype::t_dummy_sink_reactor_in_mrm_dag_sink_reactor::DUMMYSINKREACTORDAGSINKREACTOR.c_dag_sink_reactor.main(&control);
		},
		vec![Cow::from("Control")],
		SchedulerType::PrioritizedFIFO(7),
		Duration::from_secs(1),
	)
	.await;

	use tecs_signature::s_ekf_localizer::*;

	spawn_sink_reactor::<_, (TwistWithCovarianceStamped,)>(
		"EkfLocalizer".into(),
		|(twist,): (TwistWithCovarianceStamped,)| {
			tecs_celltype::t_ekf_localizer_sink_reactor::EKFLOCALIZERSINKREACTOR.c_sink_reactor.main(&twist);
		},
		vec![Cow::from("TwistWithCovarianceG")],
		SchedulerType::PrioritizedFIFO(7),
		Duration::from_secs(1),
	)
	.await;

	use tecs_signature::s_dummy_periodic_reactor_in_mrm::*;

	dag.register_periodic_reactor::<_, (Frame,VelocityReport,)>(
		"DummyPeriodicReactorInMrm".into(),
		|| -> (Frame,VelocityReport,) {
			let mut imu: Frame = Default::default();
			let mut velocity_status: VelocityReport = Default::default();
			tecs_celltype::t_dummy_periodic_reactor_in_mrm_dag_periodic_reactor::DUMMYHARDWAREDAGPERIODICREACTOR.c_dag_periodic_reactor.main(&mut imu, &mut velocity_status);
			(imu,velocity_status,)
		},
		vec![Cow::from("Imu, VelocityStatus")],
		SchedulerType::PrioritizedFIFO(7),
		Duration::from_millis(50),
	)
	.await;

	use tecs_signature::s_ekf_localizer_timer::*;

	dag.register_periodic_reactor::<_, (KinematicState,)>(
		"EkfLocalizerTimer".into(),
		|| -> (KinematicState,) {
			let mut kinematic_state: KinematicState = Default::default();
			tecs_celltype::t_ekf_localizer_timer_dag_periodic_reactor::EKFLOCALIZERTIMERDAGPERIODICREACTOR.c_dag_periodic_reactor.main(&mut kinematic_state);
			(kinematic_state,)
		},
		vec![Cow::from("KinematicState")],
		SchedulerType::PrioritizedFIFO(7),
		Duration::from_millis(50),
	)
	.await;

	let _ = finish_create_dags(&[dag.clone()]).await;
}
