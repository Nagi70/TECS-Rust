use crate::tecs_global::*;
use crate::tecs_celltype::t_ekf_localizer_timer::*;
use crate::tecs_signature::{s_kinematic_state::*, s_ekf_module::*, s_twist_with_covariance_get::*, s_ekf_localizer_timer::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SEkfLocalizerTimer for EReactorForTEkfLocalizerTimer{

	fn main(&'static self, kinematic_state: &mut KinematicState) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);
		// 現在時刻取得
		let now = awkernel_lib::time::Time::now();

		// dt 計算
		let dt = now.saturating_duration_since(lg.var.last_predict_time);
		lg.var.ekf_dt = (dt.as_nanos() as f64) * 1.0e-9;

		// dt 上限（C++ 相当の安全弁）
		if lg.var.ekf_dt > 10.0 { lg.var.ekf_dt = 10.0; }

		// 遅延時間の蓄積と予測実行
		lg.c_ekf_module.accumulate_delay_time(&lg.var.ekf_dt);
		lg.c_ekf_module.predict_with_delay(&lg.var.ekf_dt);

		// 現在時刻を保存
		lg.var.last_predict_time = now;

		// Twist 測定更新（姿勢の測定更新は行わない: デッドレコニング）
		// キューを空になるまで処理（pop は再キューしない実装）
		while let Some(twist) = lg.c_queue.pop_increment_age() {
			// 低速時は vx の分散を大きくする（C++ の購読側の処理をここで反映）
			match lg.c_ekf_module.measurement_update_twist(&twist, &now) {
				Ok(()) => {},
				Err(e) => {
					match e {
						EkfModuleError::DelayTime => {
							log::warn!("Twist measurement delay time is too large, skipping this measurement update.");
						},
						EkfModuleError::InvalidTwistMeasurement => {
							log::warn!("Twist measurement covariance is invalid, skipping this measurement update.");
						},
						EkfModuleError::TwistGate => {
							log::warn!("Twist measurement is out of gate, skipping this measurement update.");
						},
						_ => {}, // その他のエラーは無視して続行
					}
				}
			}
		}

		// 最新の推定結果を取り出して KinematicState に格納（Pose と Twist）
		let mut pose_out = PoseWithCovarianceStamped::default();
		let get_biased_yaw = false;
		lg.c_ekf_module.get_current_pose(&now, &get_biased_yaw, &mut pose_out);
		let mut tw_out = TwistWithCovarianceStamped::default();
		lg.c_ekf_module.get_current_twist(&now, &mut tw_out);

		// Header / child frame id を設定
		kinematic_state.header.time_stamp = now;
		kinematic_state.child_frame_id.clear();
		let _ = kinematic_state.child_frame_id.push_str("base_link");

		// Pose / Twist 値を反映
		kinematic_state.pose.pose = pose_out.pose.pose;
		kinematic_state.twist.twist = tw_out.twist.twist;

		// 共分散を反映
		lg.c_ekf_module.get_current_pose_covariance(&mut kinematic_state.pose.covariance);
		lg.c_ekf_module.get_current_twist_covariance(&mut kinematic_state.twist.covariance);
	}
}

