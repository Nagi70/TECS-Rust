use crate::tecs_global::*;
use crate::tecs_celltype::t_twist2_accel::*;
use crate::tecs_signature::{s_accel_with_covariance_stamped::*, s_kinematic_state::*, s_twist2_accel::*, s_lowpass1d::*};
use awkernel_lib::sync::mutex::MCSNode;
impl SKinematicState for EKinematicStateForTTwist2Accel{

	fn send(&'static self, kinematic_state: &KinematicState) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

	}
}

impl STwist2Accel for EReactorForTTwist2Accel{

	fn main(&'static self, twist: &KinematicState, accel: &mut AccelWithCovarianceStamped) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		// Set header from input (equivalent to accel_msg.header = msg->header)
		accel.header = twist.header.clone();

		// Compute dt between current and previous twist timestamps
		let prev_stamp = lg.var.prev_twist.header.time_stamp;
		let curr_stamp = twist.header.time_stamp;

		// Only compute acceleration if we have a valid previous sample
		if prev_stamp != awkernel_lib::time::Time::zero() {
			let dt_dur = curr_stamp.saturating_duration_since(prev_stamp);
			let mut dt = dt_dur.as_secs_f64();
			if dt < 1.0e-3 { dt = 1.0e-3; }

			// Differences of twist components
			let cur = &twist.twist.twist;
			let prev = &lg.var.prev_twist.twist;

			let alx = (cur.linear.x - prev.linear.x) / dt;
			let aly = (cur.linear.y - prev.linear.y) / dt;
			let alz = (cur.linear.z - prev.linear.z) / dt;
			let aax = (cur.angular.x - prev.angular.x) / dt;
			let aay = (cur.angular.y - prev.angular.y) / dt;
			let aaz = (cur.angular.z - prev.angular.z) / dt;

			// Apply low-pass filters for each axis
			// Populate output accel message
			lg.c_filter_alx.filter(&alx, &mut accel.accel.accel.linear.x);
			lg.c_filter_aly.filter(&aly, &mut accel.accel.accel.linear.y);
			lg.c_filter_alz.filter(&alz, &mut accel.accel.accel.linear.z);
			lg.c_filter_aax.filter(&aax, &mut accel.accel.accel.angular.x);
			lg.c_filter_aay.filter(&aay, &mut accel.accel.accel.angular.y);
			lg.c_filter_aaz.filter(&aaz, &mut accel.accel.accel.angular.z);

			// Set diagonal covariance (same as C++ reference implementation)
			accel.accel.covariance[(0, 0)] = 1.0;
			accel.accel.covariance[(1, 1)] = 1.0;
			accel.accel.covariance[(2, 2)] = 1.0;
			accel.accel.covariance[(3, 3)] = 0.05;
			accel.accel.covariance[(4, 4)] = 0.05;
			accel.accel.covariance[(5, 5)] = 0.05;
		}

		// Update previous twist for next iteration
		lg.var.prev_twist.header = twist.header.clone();
		lg.var.prev_twist.twist = twist.twist.twist.clone();
	}
}

