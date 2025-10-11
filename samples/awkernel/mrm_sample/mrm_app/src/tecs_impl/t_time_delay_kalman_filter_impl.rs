use crate::tecs_global::*;
use crate::tecs_celltype::t_time_delay_kalman_filter::*;
use crate::tecs_signature::s_time_delay_kalman_filter::*;
use awkernel_lib::sync::mutex::MCSNode;
impl STimeDelayKalmanFilter for EKalmanForTTimeDelayKalmanFilter{

	fn init(&'static self, x: &nalgebra::Matrix6x1<f64>, p: &nalgebra::Matrix6<f64>) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let n = *lg.dim_x as usize; // 6
		let n_ex = *lg.dim_x_ex as usize; // n * max_delay
		let max_steps_cap = *lg.max_delay_step as usize;

		// Initialize extended state: replicate x for each delay slot (use nalgebra slices)
		for k in 0..max_steps_cap {
			let off = k * n;
			lg.var.x.rows_mut(off, n).copy_from(x);
		}

		// Initialize extended covariance as block-diagonal with p on each block, zeros elsewhere
		// lg.var.p.fill(0.0);
		for k in 0..max_steps_cap {
			let off = k * n;
			lg.var.p.slice_mut((off, off), (n, n)).copy_from(p);
		}

		// Note: 'steps' currently not stored; the filter operates up to the compiled capacity.
	}
	fn predict_with_delay(&'static self, x_next: &nalgebra::Matrix6x1<f64>, a: &nalgebra::Matrix6<f64>, q: &nalgebra::Matrix6<f64>) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let n = *lg.dim_x as usize; // 6
		let n_ex = *lg.dim_x_ex as usize; // 300
		let d_dim = *lg.d_dim_x as usize; // n_ex - n
		let max_steps_cap = *lg.max_delay_step as usize;

		// Predict state: shift older states down and place x_next at the head (use slices)
		let mut x_tmp: nalgebra::SVector<f64, 300> = nalgebra::SVector::zeros();
		x_tmp.rows_mut(0, n).copy_from(x_next);
		x_tmp.rows_mut(n, d_dim).copy_from(&lg.var.x.rows(0, d_dim));

		// Predict covariance with structured A_ex and Q_ex using block ops
		let mut p_tmp: nalgebra::SMatrix<f64, 300, 300> = nalgebra::SMatrix::zeros();
		p_tmp.fill(0.0);
		// Top-left: A * P11 * A^T + Q
		let p11_old = lg.var.p.slice((0, 0), (n, n));
		let p11_new = a * p11_old * a.transpose() + q;
		p_tmp.slice_mut((0, 0), (n, n)).copy_from(&p11_new);
		// Top-right: A * P(0, 0..d_dim)
		let p1r_old = lg.var.p.slice((0, 0), (n, d_dim));
		let tr = a * p1r_old; // 6 x d_dim
		p_tmp.slice_mut((0, n), (n, d_dim)).copy_from(&tr);
		// Bottom-left: P(0..d_dim, 0) * A^T
		let plc_old = lg.var.p.slice((0, 0), (d_dim, n));
		let bl = plc_old * a.transpose(); // d_dim x 6
		p_tmp.slice_mut((n, 0), (d_dim, n)).copy_from(&bl);
		// Bottom-right: P(0..d_dim, 0..d_dim)
		let br_old = lg.var.p.slice((0, 0), (d_dim, d_dim));
		p_tmp.slice_mut((n, n), (d_dim, d_dim)).copy_from(&br_old);

		// Commit
		lg.var.x = x_tmp;
		lg.var.p = p_tmp;
	}
	fn update_with_delay(&'static self, y: &nalgebra::Matrix2x1<f64>, c: &nalgebra::Matrix2x6<f64>, r: &nalgebra::Matrix2<f64>, delay_step: &i32) -> Result<(), KalmanFilterError>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let n = *lg.dim_x as usize; // 6
		let n_ex = *lg.dim_x_ex as usize; // 300
		let max_steps_cap = *lg.max_delay_step as usize;
		let d = if *delay_step >= 0 { *delay_step as usize } else { 0 };
		if d >= max_steps_cap { return Err(KalmanFilterError::InvalidDelayStep); }
		let blk = d * n;

		// Innovation v = y - c * x_block
		let mut x_block: nalgebra::Vector6<f64> = nalgebra::Vector6::zeros();
		for i in 0..n { x_block[i] = lg.var.x[blk + i]; }
		let v = y - c * x_block;

		// S = c * P_block * c^T + r (2x2)
		let p_blk_view = lg.var.p.slice((blk, blk), (n, n));
		let mut s_mat: nalgebra::Matrix2<f64> = c * p_blk_view * c.transpose();
		s_mat += r;

		// Invert 2x2 S manually for robustness
		let a11 = s_mat[(0,0)]; let a12 = s_mat[(0,1)];
		let a21 = s_mat[(1,0)]; let a22 = s_mat[(1,1)];
		let det = a11 * a22 - a12 * a21;
		if det.abs() < 1.0e-12 { return Ok(()); }
		let inv_det = 1.0 / det;
		let s_inv = nalgebra::Matrix2::new( a22 * inv_det, -a12 * inv_det,
			                               -a21 * inv_det,  a11 * inv_det );

		// t = S_inv * v (2x1)
		let t = s_inv * v;
		// z = c^T * t (6x1)
		let z: nalgebra::Vector6<f64> = c.transpose() * t;

		// P_col = P[:, blk..blk+n] (dim_ex x 6)
		let p_col = lg.var.p.slice((0, blk), (n_ex, n)).into_owned(); // clone to avoid aliasing
		// Update x: x += P_col * z
		lg.var.x += &p_col * z;

		// Compute M = c^T * S_inv * c (6x6)
		let w: nalgebra::Matrix2x6<f64> = s_inv * c; // 2x6
		let m: nalgebra::Matrix6<f64> = c.transpose() * w; // 6x6
		// P -= (P_col * M) * P_col^T
		let u = &p_col * m; // dim_ex x 6
		lg.var.p -= u * p_col.transpose();

		Ok(())
	}
	fn get_latest_x(&'static self) -> nalgebra::Matrix6x1<f64>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let n = *lg.dim_x as usize;
		let mut out = nalgebra::Matrix6x1::<f64>::zeros();
		for i in 0..n { out[(i,0)] = lg.var.x[i]; }
		out
	}
	fn get_latest_p(&'static self) -> nalgebra::Matrix6<f64>{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let n = *lg.dim_x as usize;
		let mut out = nalgebra::Matrix6::<f64>::zeros();
		for i in 0..n { for j in 0..n { out[(i,j)] = lg.var.p[(i,j)]; } }
		out
	}
	fn get_xelement(&'static self, i: &u32) -> f64{
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let idx = *i as usize;
		let n_ex = *lg.dim_x_ex as usize;
		if idx < n_ex { lg.var.x[idx] } else { 0.0 }
	}
}

