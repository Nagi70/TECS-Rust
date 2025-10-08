use crate::tecs_global::*;
use crate::tecs_celltype::t_ekf_localizer_timer::*;
use crate::tecs_signature::{s_kinematic_state::*, s_ekf_module::*, s_twist_with_covariance_get::*, s_ekf_localizer_timer::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SEkfLocalizerTimer for EReactorForTEkfLocalizerTimer<'_>{

	fn main(&'static self, kinematic_state: &mut KinematicState) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);
		// 現在時刻取得
		let now = awkernel_lib::time::Time::now();

		// dt 計算（前回時刻が未設定なら既定の ekf_rate を使用）
		let mut dt_sec: f64;
		if lg.var.last_predict_time == awkernel_lib::time::Time::zero() {
			dt_sec = *lg.ekf_rate; // 初回は既定の周期
		} else {
			let dt = now.saturating_duration_since(lg.var.last_predict_time);
			dt_sec = (dt.as_nanos() as f64) * 1.0e-9;
			if dt_sec <= 0.0 { dt_sec = *lg.ekf_rate; }
		}
		// dt 上限（C++ 相当の安全弁）
		if dt_sec > 10.0 { dt_sec = 10.0; }

		// 遅延時間の蓄積と予測実行
		lg.c_ekf_module.accumulate_delay_time(&dt_sec);
		lg.c_ekf_module.predict_with_delay(&dt_sec);

		// 現在時刻を保存
		lg.var.last_predict_time = now;
		lg.var.ekf_dt = dt_sec;

		// Twist 測定更新（姿勢の測定更新は行わない: デッドレコニング）
		// キューを空になるまで処理（pop は再キューしない実装）
		while let Some(mut twist) = lg.c_queue.pop() {
			// 低速時は vx の分散を大きくする（C++ の購読側の処理をここで反映）
			if twist.twist.twist.linear.x.abs() < *lg.threshold_observable_velocity_mps {
				// covariance の (0,0) = vx の分散
				twist.twist.covariance[(0, 0)] = 10000.0;
			}
			let _ = lg.c_ekf_module.measurement_update_twist(&twist, &now);
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
		kinematic_state.pose.pose = pose_out.pose;
		kinematic_state.twist.twist = tw_out.twist.twist;

		// 共分散を反映
		lg.c_ekf_module.get_current_pose_covariance(&mut kinematic_state.pose.covariance);
		lg.c_ekf_module.get_current_twist_covariance(&mut kinematic_state.twist.covariance);
	}
}

