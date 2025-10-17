use crate::tecs_global::*;
use crate::tecs_celltype::t_time_delay_kalman_filter::*;
use crate::tecs_signature::s_time_delay_kalman_filter::*;
use awkernel_lib::sync::mutex::MCSNode;
impl STimeDelayKalmanFilter for EKalmanForTTimeDelayKalmanFilter{

	fn init(&self, x: &nalgebra::Matrix6x1<f64>, p: &nalgebra::Matrix6<f64>) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let n = *lg.dim_x as usize; // 6
		let n_ex = *lg.dim_x_ex as usize; // n * max_delay
		let max_steps_cap = *lg.max_delay_step as usize;

		// Build extended state and covariance locally, then store into Options
		let mut x_ex: nalgebra::SVector<f64, 300> = nalgebra::SVector::zeros();
		for k in 0..max_steps_cap {
			let off = k * n;
			x_ex.rows_mut(off, n).copy_from(x);
		}

		let mut p_ex: nalgebra::SMatrix<f64, 300, 300> = nalgebra::SMatrix::zeros();
		for k in 0..max_steps_cap {
			let off = k * n;
			p_ex.slice_mut((off, off), (n, n)).copy_from(p);
		}

		lg.var.x = Some(x_ex);
		lg.var.p = Some(p_ex);

		// Note: 'steps' currently not stored; the filter operates up to the compiled capacity.
	}
	fn predict_with_delay(&self, x_next: &nalgebra::Matrix6x1<f64>, a: &nalgebra::Matrix6<f64>, q: &nalgebra::Matrix6<f64>) {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let n = *lg.dim_x as usize; // 6
		let n_ex = *lg.dim_x_ex as usize; // 300
		let d_dim = *lg.d_dim_x as usize; // n_ex - n
		let max_steps_cap = *lg.max_delay_step as usize;

		// Access current state/covariance (must be initialized in init)
		let x_old = lg.var.x.as_ref().unwrap();
		let p_old = lg.var.p.as_ref().unwrap();

		// Predict state: shift older states down and place x_next at the head
		let mut x_tmp: nalgebra::SVector<f64, 300> = nalgebra::SVector::zeros();
		x_tmp.rows_mut(0, n).copy_from(x_next);
		x_tmp.rows_mut(n, d_dim).copy_from(&x_old.rows(0, d_dim));

		// Predict covariance with structured A_ex and Q_ex using block ops
		let mut p_tmp: nalgebra::SMatrix<f64, 300, 300> = nalgebra::SMatrix::zeros();
		p_tmp.fill(0.0);
		// Top-left: A * P11 * A^T + Q, where P11 is 6x6 block at (0,0)
		let mut p11_old_mat = nalgebra::Matrix6::<f64>::zeros();
		for r in 0..n { for c in 0..n { p11_old_mat[(r,c)] = p_old[(r, c)]; } }
		let p11_new = a * p11_old_mat * a.transpose() + q;
		p_tmp.slice_mut((0, 0), (n, n)).copy_from(&p11_new);
		// Top-right: A * P(0..n, 0..d_dim) -> place into columns [n .. n+d_dim)
		for j in 0..d_dim {
			let mut col = nalgebra::Vector6::<f64>::zeros();
			for i in 0..n { col[i] = p_old[(i, j)]; }
			let out_col = a * col; // 6x1
			for i in 0..n { p_tmp[(i, n + j)] = out_col[i]; }
		}
		// Bottom-left: transpose of top-right result (since P is symmetric)
		for i in 0..d_dim { for j in 0..n { p_tmp[(n + i, j)] = p_tmp[(j, n + i)]; } }
		// Bottom-right: copy previous block as in original implementation
		for r in 0..d_dim { for c in 0..d_dim { p_tmp[(n + r, n + c)] = p_old[(r, c)]; } }

		// Commit
		lg.var.x = Some(x_tmp);
		lg.var.p = Some(p_tmp);
	}
	fn update_with_delay(&self, y: &nalgebra::Matrix2x1<f64>, c: &nalgebra::Matrix2x6<f64>, r: &nalgebra::Matrix2<f64>, delay_step: &i32) -> Result<(), KalmanFilterError> {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let n = *lg.dim_x as usize; // 6
		let n_ex = *lg.dim_x_ex as usize; // 300
		let max_steps_cap = *lg.max_delay_step as usize;
		let d = if *delay_step >= 0 { *delay_step as usize } else { 0 };
		if d >= max_steps_cap { return Err(KalmanFilterError::InvalidDelayStep); }
		let blk = d * n;

		// Innovation v = y - c * x_block
		let x_ref = lg.var.x.as_ref().unwrap();
		let mut x_block: nalgebra::Vector6<f64> = nalgebra::Vector6::zeros();
		for i in 0..n { x_block[i] = x_ref[blk + i]; }
		let v = y - c * x_block;

		// S = c * P_block * c^T + r (2x2)
		let mut p_blk_mat = nalgebra::Matrix6::<f64>::zeros();
		{
			let p_ref = lg.var.p.as_ref().unwrap();
			for r in 0..n { for c in 0..n { p_blk_mat[(r,c)] = p_ref[(blk + r, blk + c)]; } }
		}
		let mut s_mat: nalgebra::Matrix2<f64> = c * p_blk_mat * c.transpose();
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
		// Avoid dynamic allocation: copy into a fixed-size matrix (dim_ex is compile-time 300, n is 6)
		let mut p_col: nalgebra::SMatrix<f64, 300, 6> = nalgebra::SMatrix::zeros();
		{
			let p_ref = lg.var.p.as_ref().unwrap();
			for rr in 0..n_ex {
				for cc in 0..n { p_col[(rr, cc)] = p_ref[(rr, blk + cc)]; }
			}
		}
		// Update x: x += P_col * z
		{
			let x_mut = lg.var.x.as_mut().unwrap();
			*x_mut += &p_col * z;
		}

		// Compute M = c^T * S_inv * c (6x6)
		let w: nalgebra::Matrix2x6<f64> = s_inv * c; // 2x6
		let m: nalgebra::Matrix6<f64> = c.transpose() * w; // 6x6
		// P -= (P_col * M) * P_col^T
		let u = &p_col * m; // dim_ex x 6
		{
			let p_mut = lg.var.p.as_mut().unwrap();
			*p_mut -= u * p_col.transpose();
		}

		Ok(())
	}
	fn get_latest_x(&self) -> nalgebra::Matrix6x1<f64> {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let n = *lg.dim_x as usize;
		let mut out = nalgebra::Matrix6x1::<f64>::zeros();
		let x_ref = lg.var.x.as_ref().unwrap();
		for i in 0..n { out[(i,0)] = x_ref[i]; }
		out
	}
	fn get_latest_p(&self) -> nalgebra::Matrix6<f64> {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let n = *lg.dim_x as usize;
		let mut out = nalgebra::Matrix6::<f64>::zeros();
		let p_ref = lg.var.p.as_ref().unwrap();
		for i in 0..n { for j in 0..n { out[(i,j)] = p_ref[(i,j)]; } }
		out
	}
	fn get_xelement(&self, i: &u32) -> f64 {
		let mut node = MCSNode::new();
		let mut lg = self.cell.get_cell_ref(&mut node);

		let idx = *i as usize;
		let n_ex = *lg.dim_x_ex as usize;
		let x_ref = lg.var.x.as_ref().unwrap();
		if idx < n_ex { x_ref[idx] } else { 0.0 }
	}
}

