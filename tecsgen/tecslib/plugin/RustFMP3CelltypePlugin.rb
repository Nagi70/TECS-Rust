# -*- coding: utf-8 -*-
#
#  TECS Generator
#      Generator for TOPPERS Embedded Component System
#  
#   Copyright (C) 2008-2023 by TOPPERS Project
#--
#   上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
#   ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
#   変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
#   (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
#       権表示，この利用条件および下記の無保証規定が，そのままの形でソー
#       スコード中に含まれていること．
#   (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
#       用できる形で再配布する場合には，再配布に伴うドキュメント（利用
#       者マニュアルなど）に，上記の著作権表示，この利用条件および下記
#       の無保証規定を掲載すること．
#   (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
#       用できない形で再配布する場合には，次のいずれかの条件を満たすこ
#       と．
#     (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
#         作権表示，この利用条件および下記の無保証規定を掲載すること．
#     (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
#         報告すること．
#   (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
#       害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
#       また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
#       由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
#       免責すること．
#  
#   本ソフトウェアは，無保証で提供されているものである．上記著作権者お
#   よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
#   に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
#   アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
#   の責任を負わない．
#  
#   $Id: CelltypePlugin.rb 2952 2018-05-07 10:19:07Z okuma-top $
#++

require_tecsgen_lib "RustITRONCelltypePlugin.rb"

#== celltype プラグインの共通の親クラス
class RustFMP3CelltypePlugin < RustITRONCelltypePlugin
    CLASS_NAME_SUFFIX = ""

    #celltype::     Celltype        セルタイプ（インスタンス）
    def initialize( celltype, option )
      super
      @celltype = celltype
      @plugin_arg_str = option.gsub( /\A"(.*)/, '\1' )    # 前後の "" を取り除く
      @plugin_arg_str.sub!( /(.*)"\z/, '\1' )
      @plugin_arg_str = CDLString.remove_dquote option
      @plugin_arg_list = {}
      @cell_list =[]
      celltype.set_impl_lang :Rust
    end
  
    #=== 新しいセル
    #cell::        Cell            セル
    #
    # celltype プラグインを指定されたセルタイプのセルが生成された
    # セルタイププラグインに対する新しいセルの報告
    def new_cell( cell )
        @cell_list << cell
    end
    
    #=== 後ろの CDL コードを生成
    #プラグインの後ろの CDL コードを生成
    #file:: File: 
    def self.gen_post_code( file )
      # 複数のプラグインの post_code が一つのファイルに含まれるため、以下のような見出しをつけること
      # file.print "/* '#{self.class.name}' post code */\n"
    end

    # タスクの静的APIの生成は FMPPlugin が行うため、このプラグインはヘッダファイルなどのインクルード生成を行う
    def gen_task_static_api_for_configuration cell
        id = cell.get_attr_initializer("id".to_sym)

        # TODO: Rust のタスク関数を呼び出すための extern 宣言をインクルードするための生成であり、将来的には削除できるかも
        if @@rust_tecs_header_include == false then
            file = AppFile.open( "#{$gen}/tecsgen.cfg" )
            file.print "#include \"rust_tecs.h\"\n"
            file.close
            @@rust_tecs_header_include = true
        end

        gen_rust_tecs_h "tecs_rust_start_#{snake_case(cell.get_global_name.to_s)}"

        # TODO: タスクオブジェクトのダミーIDはすべて0で生成しているが、変えてもいいかもしれない
        add_dummy_id_to_kernel_cfg_rs "#{id}", 0

    end

    # CRE_ISR の生成は FMPPlugin が行うため、このプラグインはヘッダファイルなどのインクルード生成を行う
    # TODO: リファクタリングの際に、タスクや他のハンドラの関数と一緒にしたい
    def gen_isr_static_api_for_configuration cell
        id = cell.get_attr_initializer("id".to_sym)

        # TODO: Rust のタスク関数を呼び出すための extern 宣言をインクルードするための生成であり、将来的には削除できるかも
        if @@rust_tecs_header_include == false then
            file = AppFile.open( "#{$gen}/tecsgen.cfg" )
            file.print "#include \"rust_tecs.h\"\n"
            file.close
            @@rust_tecs_header_include = true
        end

        gen_rust_tecs_h "tecs_rust_start_#{snake_case(cell.get_global_name.to_s)}"

        # TODO: タスクオブジェクトのダミーIDはすべて0で生成しているが、変えてもいいかもしれない
        add_dummy_id_to_kernel_cfg_rs "#{id}", 0
    end

    # ATT_INI の生成は FMPPlugin が行うため、このプラグインはヘッダファイルなどのインクルード生成を行う
    # TODO: リファクタリングの際に、タスクや他のハンドラの関数と一緒にしたい
    def gen_ini_static_api_for_configuration cell

        # TODO: Rust のタスク関数を呼び出すための extern 宣言をインクルードするための生成であり、将来的には削除できるかも
        if @@rust_tecs_header_include == false then
            file = AppFile.open( "#{$gen}/tecsgen.cfg" )
            file.print "#include \"rust_tecs.h\"\n"
            file.close
            @@rust_tecs_header_include = true
        end

        gen_rust_tecs_h "tecs_rust_start_#{snake_case(cell.get_global_name.to_s)}"
    end

    # itron のコンフィグレーションファイルにミューテックス静的APIを生成する
    # TODO: ミューテックスの静的APIをどこのクラスに配置するべきかを決める必要がありそう
    def gen_mutex_static_api_for_configuration cell
        file = AppFile.open( "#{$gen}/tecsgen.cfg" )

        # TODO: 優先度上限か、優先度継承かをプラグインオプションで判断できるようにする
        # file.print "CRE_MTX( TECS_RUST_EX_CTRL_#{@@ex_ctrl_ref_id}, { TA_INHERIT });\n"

        # 優先度上限値の取得
        ceiling_priority = get_ceiling_priority cell
        file.print "CRE_MTX( TECS_RUST_EX_CTRL_#{@@ex_ctrl_ref_id}, { TA_CEILING, #{ceiling_priority} });\n"
        file.close

        add_dummy_id_to_kernel_cfg_rs "TECS_RUST_EX_CTRL_#{@@ex_ctrl_ref_id}", @@ex_ctrl_ref_id

        @@ex_ctrl_ref_id += 1
    end

    # itron のコンフィグレーションファイルにセマフォ静的APIを生成する
    # TODO: セマフォの静的APIをどこのクラスに配置するべきかを決める必要がありそう
    def gen_semaphore_static_api_for_configuration cell
        file = AppFile.open( "#{$gen}/tecsgen.cfg" )

        # 資源数 1 でセマフォを生成
        file.print "CRE_SEM( TECS_RUST_EX_CTRL_#{@@ex_ctrl_ref_id}, { TA_NULL, 1, 1 });\n"
        file.close

        add_dummy_id_to_kernel_cfg_rs "TECS_RUST_EX_CTRL_#{@@ex_ctrl_ref_id}", @@ex_ctrl_ref_id

        @@ex_ctrl_ref_id += 1
    end

    # Cargo.toml の設定を変更する
    def change_cargo_toml path
        cargo_toml_path = "#{path}/Cargo.toml"

        # TODO: asp3 か fmp3 かは、何かしらで判断する必要がある
        itron_rs_depenence = "itron = { version = \"= 0.1.9\", features = [\"fmp3\", \"nightly\", \"unstable\"] }"

        File.open(cargo_toml_path, "a") do |file|
            file.puts itron_rs_depenence
            file.puts ""
        end

        super(path)
    end

    # cargo.toml の設定を生成する
    def gen_config_toml path
        config_toml_dir = "#{path}/.cargo"
        comfig_toml_path = "#{config_toml_dir}/config.toml"

        return if Dir.exist?(config_toml_dir)

        Dir.mkdir(config_toml_dir)
        File.open(comfig_toml_path, "w") do |file|
            file.puts "[build]"
            file.puts "target = \"armv7a-none-eabi\"          # Bare Armv7-A (e.g., Zynq-7000 (Xilinx))"
        end
    end

    # syslog の Rust ラップである print.rs を生成する
    def gen_tecs_print_rs
        contents = <<~'EOS'
use itron::abi::*;

extern "C"{
    pub fn syslog_wri_log(prio: u32, p_syslog: *const Syslog) -> ER;
}

pub type Intprt = u32;
pub type HrtCnt = u32;
pub type Id = i32;

#[repr(C)]
pub struct Syslog {
    pub logtype: u32,
    pub logtim: HrtCnt,
    pub prcid: Id,
    pub loginfo: [Intprt; TMAX_LONINFO],
}

const TMAX_LONINFO: usize = 6;

pub const LOG_TYPE_COMMENT: u32 = 0x1;
pub const LOG_EMERG: u32 = 0x0;
pub const LOG_ALERT: u32 = 0x1;
pub const LOG_CRIT: u32 = 0x2;
pub const LOG_ERROR: u32 = 0x3;
pub const LOG_WARNING: u32 = 0x4;
pub const LOG_NOTICE: u32 = 0x5;
pub const LOG_INFO: u32 = 0x6;
pub const LOG_DEBUG: u32 = 0x7;

#[no_mangle]
#[macro_export]
#[macro_use]
macro_rules! print{
    ($fmt : expr, $($arg : expr),*) => {

        let ini_ary = {
            let mut ary : [Intprt; 6] = [0; 6];

            ary[0] = concat!($fmt, '\0').as_bytes().as_ptr() as Intprt;

            let mut _index = 1;
            $(
                {
                    ary[_index] = $arg as Intprt;
                    _index = _index + 1;
                }
            )*
            ary
        } ; 

        let mut _syslog = Syslog {
            logtype : LOG_TYPE_COMMENT,
            logtim : 0,
            prcid : 0,
            loginfo : ini_ary
        };

        unsafe{
            let _ = syslog_wri_log(LOG_NOTICE, &_syslog);
        }
    };
}
            EOS

        # get_diff_between_gen_and_src "tecs_print.rs"
        print_file = CFile.open( "#{$gen}/tecs_print.rs", "w" )
        print_file.print contents
        print_file.close

        if File.exist?("#{@@cargo_path}/tecs_print.rs") == false then
            copy_gen_files_to_cargo "tecs_print.rs"
        end
    end

    #=== tCelltype_factory.h に挿入するコードを生成する
    # file 以外の他のファイルにファクトリコードを生成してもよい
    # セルタイププラグインが指定されたセルタイプのみ呼び出される
    def gen_factory file
        super(file)
    end
end
