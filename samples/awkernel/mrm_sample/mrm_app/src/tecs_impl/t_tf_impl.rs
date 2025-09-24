use crate::tecs_struct_def::*;
use crate::tecs_celltype::t_tf::*;
use crate::tecs_signature::s_tf::*;
use awkernel_lib::sync::mutex::MCSNode;
impl STf for ETfForTTf<'_>{

	fn transform_covariance(&'static self, cov: &nalgebra::Matrix3<f64>) -> nalgebra::Matrix3<f64>{
		let mut lg = self.cell.get_cell_ref();

		// 対角成分から最大値を見つける
        let max_cov = cov.diagonal().max();

		// 新しい共分散行列を作成
        // zeros()で0行列を作成し、diagonal()で対角要素にアクセス
        let cov_transformed = nalgebra::Matrix3::new(
			max_cov, 0.0, 0.0,
			0.0, max_cov, 0.0,
			0.0, 0.0, max_cov
		);
        
        cov_transformed
	}
	fn transform_vector3(&'static self, vec: &mut nalgebra::Vector3<f64>) -> nalgebra::Vector3<f64> {
		let mut lg = self.cell.get_cell_ref();

		lg.transform * *vec
	}
}

