use crate::tecs_global::*;
use crate::tecs_celltype::t_stop_filter::*;
use crate::tecs_signature::{s_kinematic_state::*, s_stop_filter::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SKinematicState for EKinematicStateForTStopFilter{

	fn send(&'static self, kinematic_state: &KinematicState) {
		let mut lg = self.cell.get_cell_ref();

	}
}

impl SStopFilter for EReactorForTStopFilter{

	fn main(&'static self, odom_in: &KinematicState, odom_out: &mut KinematicState) {
		let mut lg = self.cell.get_cell_ref();

        // 停止判定: |vx| < vx_threshold かつ |wz| < wz_threshold
        let was_stopped =
            odom_in.twist.twist.linear.x.abs() < *lg.vx_threshold &&
            odom_in.twist.twist.angular.z.abs() < *lg.wz_threshold;

        if was_stopped {
            // 停止: 速度をゼロに補正
            odom_out.twist.twist.linear.x = 0.0;
            odom_out.twist.twist.linear.y = 0.0;
            odom_out.twist.twist.linear.z = 0.0;
            odom_out.twist.twist.angular.x = 0.0;
            odom_out.twist.twist.angular.y = 0.0;
            odom_out.twist.twist.angular.z = 0.0;
        } else {
            // 通過: 入力をそのまま出力
            odom_out.twist.twist.linear.x = odom_in.twist.twist.linear.x;
            odom_out.twist.twist.linear.y = odom_in.twist.twist.linear.y;
            odom_out.twist.twist.linear.z = odom_in.twist.twist.linear.z;
            odom_out.twist.twist.angular.x = odom_in.twist.twist.angular.x;
            odom_out.twist.twist.angular.y = odom_in.twist.twist.angular.y;
            odom_out.twist.twist.angular.z = odom_in.twist.twist.angular.z;
        }
	}
}

