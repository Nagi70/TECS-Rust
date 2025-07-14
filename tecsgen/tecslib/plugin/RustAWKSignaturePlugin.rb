# -*- coding: utf-8 -*-
#
#  mruby => TECS bridge
#  
#   Copyright (C) 2008-2019 by TOPPERS Project
#
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

class RustAWKSignaturePlugin < SignaturePlugin


  @@b_no_banner = false         #


  #=== プラグインインスタンスの初期化
  # 戻り値、引数の型が使用可能なものかチェックする
  #
  def initialize( signature, option )
    super

    if ! @@b_no_banner
      STDERR << "MrubyBridgePlugin: version 2.0.0 (Suitable for mruby above ver 1.2.0).\n"
      @@b_no_banner = true
    end

    @b_ignoreUnsigned = false
    @includes = []
    @excludes = []
    @struct_list = { }
    @ptr_list = { }
    @auto_exclude_list = {}
    @b_auto_exclude = true     # auto_exclude = true by default 

    @plugin_arg_check_proc_tab = MrubyBridgePluginArgProc
    parse_plugin_arg

    @celltype_name = :"t#{@signature.get_global_name}"
    @init_celltype_name = :"#{@celltype_name}_Initializer"
        # this variable is sometimes not used. rhs coded directry.
    @class_name = :"T#{@signature.get_global_name}"

  end

  #=== check function name & return type
  def check_name_and_return_type func_head_array
  end

  #=== check paramter type
  def check_parameter_type func_head_array
  end

  #=== 構造体のメンバーの型のチェック
  def check_struct_member struct_type, fh
  end

  def register_ptr_type ttype, fh
  end

  def get_type_map_ent ttype
  end

  #===  CDL ファイルの生成
  #      typedef, signature, celltype, cell コードを生成
  #file::        FILE       生成するファイル
  def gen_cdl_file(file)
  end

  #=== gen_cdl_file で定義したセルタイプに 新しいセルが定義された
  # cell のセルタイプの名前は @celltype_name
  def new_cell cell
  end

  #=== プラグインが CDL の POST コードを生成
  # tmp_plugin_post_code.cdl への出力
  def self.gen_post_code file
  end

  def self.gen_post_code_body file
  end

  ####### 以下コード生成段階 ######

  #===  受け口関数の本体コードを生成（頭部と末尾は別途出力）
  #ct_name:: Symbol    (プラグインで生成された) セルタイプ名 ．Symbol として送られてくる
  def gen_ep_func_body( file, b_singleton, ct_name, global_ct_name, sig_name, ep_name, func_name, func_global_name, func_type, params )
  end

  def gen_ep_func_body_bridge( file, b_singleton, ct_name, global_ct_name, sig_name, ep_name, func_name, func_global_name, func_type, params )
  end

  def gen_ep_func_body_bridge_init( file, b_singleton, ct_name, global_ct_name, sig_name, ep_name, func_name, func_global_name, func_type, params )
  end

  #===  受け口関数の preamble (C言語)を生成する
  #     必要なら preamble 部に出力する
  #file::           FILE        出力先ファイル
  #b_singleton::    bool        true if singleton
  #ct_name::        Symbol
  #global_ct_name:: string
  def gen_preamble( file, b_singleton, ct_name, global_ct_name )
  end

  def gen_preamble_mruby( file, b_singleton, ct_name, global_ct_name )
  end

  def gen_preamble_instance_proto( file, b_singleton, ct_name, global_ct_name )
  end

  def gen_preamble_instance_initialize( file, b_singleton, ct_name, global_ct_name )
  end

  def gen_preamble_bridge_func( file, b_singleton, ct_name, global_ct_name )
  end
end

