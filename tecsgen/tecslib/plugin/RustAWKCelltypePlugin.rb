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

require_tecsgen_lib "RustGenCelltypePlugin.rb"

#== celltype プラグインの共通の親クラス
class RustAWKCelltypePlugin < RustGenCelltypePlugin
    CLASS_NAME_SUFFIX = ""
    @@b_signature_header_generated = false
    @@module_generated = false
    @@arm_none_eabi_nm_gen = false
    @@kernel_cfg_rs_gen = false
    @@rust_task_func_list = []
    @@rust_hadler_func_list = []
    @@rust_tecs_header_include = false

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

    # オプションから、リアクターの種類を取得する
    def get_reactor_type
        plugin_option = @plugin_arg_str.split(",").map(&:strip)
        if plugin_option.include?("REACTOR") then
            return "Reactor"
        elsif plugin_option.include?("SINC_REACTOR") then
            return "SincReactor"
        elsif plugin_option.include?("PERIODIC_REACTOR") then
            return "PeriodicReactor"
        else
            return "unknown"
        end
    end

    # mod記述をlib.rsに生成
    def gen_main_lib_rs celltype
        plugin_option = @plugin_arg_str.split(",").map(&:strip)

        write_list = ["#![no_std]"]
        tempfile = File.read("#{$gen}/lib.rs")

        write_list.each do |write|
            if tempfile.include?(write) then
                next
            else
                tempfile << write + "\n"
            end
        end
        File.write("#{$gen}/lib.rs", tempfile)

        case reactor_type
        when "Reactor"
            gen_register_reactor celltype
        when "SincReactor"
            gen_register_sink_reactor celltype
        when "PeriodicReactor"
            gen_register_periodic_reactor celltype
        end

        super(celltype)
    end

    def gen_register_reactor celltype
        file = File.read("#{$gen}/lib.rs")

        # 一番最初のタスク関数生成の時だけ、二つのuse文を追加する
        # TODO: この2つのuse文は、ユーザの定義するセルタイプとシグニチャのインクルードを表すため、情報を抽出する必要がある
        if !file.include?("use crate::" + snake_case(celltype.get_global_name.to_s) + "::*;") then
            file << "\nuse crate::" + snake_case(celltype.get_global_name.to_s) + "::*;\n"
        end

        if !file.include?("use s_reactor_body::*;") then
            file << "use s_reactor_body::*;\n"
        end
        
        # TODO: リアクターの登録を生成する
        celltype.get_cell_list.each{ |cell|
            search_pattern = /
                \#\[\s*no_mangle\s*\]\n
                pub\s+extern\s*"C"\s+fn\s+tecs_rust_start_#{snake_case(cell.get_global_name.to_s)}\(\s*_\s*:\s*usize\s*\)\s*\{\n
                \s*#{cell.get_global_name.to_s.upcase}\.c_task_body\.main\(\);\n
            \}/x
            if !file.match?(search_pattern) then
                file << "\n#[no_mangle]\n"
                file << "pub extern \"C\" fn tecs_rust_start_" + snake_case(cell.get_global_name.to_s) + "(_: usize) {\n"
                file << "\t#{cell.get_global_name.to_s.upcase}.c_task_body.main();\n" # TODO: 呼び口である c_task_body が sTaskBody でつながっていることを前提としている
                file << "}\n"

                gen_task_static_api_for_configuration cell
            end
        }

        File.write("#{$gen}/#{file_option}.rs", file)
    end

    # lib.rs や main.rs に対して、extern関数を生成する
    # TODO: リファクタリングの際に、タスクや他のハンドラの関数と一緒にしたい
    def gen_register_sink_reactor celltype
        file = File.read("#{$gen}/#{file_option}.rs")

        # TODO: この2つのuse文は、ユーザの定義するセルタイプとシグニチャのインクルードを表すため、情報を抽出する必要がある
        if !file.include?("use crate::" + snake_case(celltype.get_global_name.to_s) + "::*;") then
            file << "\nuse crate::" + snake_case(celltype.get_global_name.to_s) + "::*;\n"
        end

        if !file.include?("use s_sink_reactor_body::*;") then
            file << "use s_sink_reactor_body::*;\n"
        end
        
        # TODO: リアクターの登録を生成する
        celltype.get_cell_list.each{ |cell|
            search_pattern = /
                \#\[\s*no_mangle\s*\]\n
                pub\s+extern\s*"C"\s+fn\s+tecs_rust_start_#{snake_case(cell.get_global_name.to_s)}\(\s*_\s*:\s*usize\s*\)\s*\{\n
                \s*#{cell.get_global_name.to_s.upcase}\.ci_isr_body\.main\(\);\n
            \}/x
            if !file.match?(search_pattern) then
                file << "\n#[no_mangle]\n"
                file << "pub extern \"C\" fn tecs_rust_start_" + snake_case(cell.get_global_name.to_s) + "(_: usize) {\n"
                file << "\t#{cell.get_global_name.to_s.upcase}.ci_isr_body.main();\n" # TODO: 呼び口である c_task_body が sTaskBody でつながっていることを前提としている
                file << "}\n"

                gen_isr_static_api_for_configuration cell
            end
        }

        File.write("#{$gen}/#{file_option}.rs", file)
    end

    def gen_register_periodic_reactor celltype
        file = File.read("#{$gen}/#{file_option}.rs")

        # TODO: この2つのuse文は、ユーザの定義するセルタイプとシグニチャのインクルードを表すため、情報を抽出する必要がある
        if !file.include?("use crate::" + snake_case(celltype.get_global_name.to_s) + "::*;") then
            file << "\nuse crate::" + snake_case(celltype.get_global_name.to_s) + "::*;\n"
        end

        if !file.include?("use s_periodic_reactor_body::*;") then
            file << "use s_periodic_reactor_body::*;\n"
        end
        
        # TODO: リアクターの登録を生成する
        celltype.get_cell_list.each{ |cell|
            search_pattern = /
                \#\[\s*no_mangle\s*\]\n
                pub\s+extern\s*"C"\s+fn\s+tecs_rust_start_#{snake_case(cell.get_global_name.to_s)}\(\s*_\s*:\s*usize\s*\)\s*\{\n
                \s*#{cell.get_global_name.to_s.upcase}\.c_initialize_routine_body\.main\(\);\n
            \}/x
            if !file.match?(search_pattern) then
                file << "\n#[no_mangle]\n"
                file << "pub extern \"C\" fn tecs_rust_start_" + snake_case(cell.get_global_name.to_s) + "(_: usize) {\n"
                file << "\t#{cell.get_global_name.to_s.upcase}.c_initialize_routine_body.main();\n" # TODO: 呼び口である c_task_body が sTaskBody でつながっていることを前提としている
                file << "}\n"

                gen_ini_static_api_for_configuration cell
            end
        }

        File.write("#{$gen}/#{file_option}.rs", file)
    end

    # セルタイプが変数を持つ場合、呼び出される
    def gen_use_mutex file

        # TODO: 将来的に排他制御の選択肢を増やす可能性がある
        case check_gen_mutex_or_not_for_celltype @celltype
        when "mutex"
            file.print "use awkernel_lib::sync::mutex::{MCSNode, Mutex, LockGuard};\n"
        when "mix"
            file.print "use awkernel_lib::sync::mutex::{MCSNode, Mutex, LockGuard};\n"
            file.print "use core::cell::UnsafeCell;\n"
        when "none"
            file.print "use core::cell::UnsafeCell;\n"
        end

        file.print "use crate::tecs_variable::*;\n"

    end

    # ミューテックスを適用するセルそうでないセルが混在するセルタイプかどうかを判断する
    # TOPPERSでは、ミューテックスとセマフォどちらかを適用する
    def check_gen_mutex_or_not_for_celltype celltype
        check_mutex = []

        celltype.get_cell_list.each{ |cell|
            check_mutex.push(check_exclusive_control_for_cell cell).uniq!
        }

        # ・ミューテックスを適用するセルと排他制御を使わないセルが混在する場合、check_mutex の中に
        # 　"mutex" と "none" が混在する場合、"mix" を返す
        if check_mutex.length >= 2 then
            return "mix"
        end

        # ・check_mutex のなかが "mutex" もしくは "none" のみの場合、それを配列から取り出して返す
        if check_mutex.length == 1 then
            return check_mutex.first
        end
    end

    # セル構造体の呼び口フィールドの定義を生成
    # TODO: ユーザが定義するReactorbodyセルタイプの呼び口をpublicにする必要がある
    def gen_rust_cell_structure_callport file, callport_list, use_jenerics_alphabet

        plugin_option = @plugin_arg_str.split(",").map(&:strip)

        callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
            # TODO: プラグインのオプションに "callback: 呼び口" がある場合は、その呼び口のみをpublicにする
            # リアクターAPIのコールバック関数で、各ルーチンの呼び口を呼び出す生成をするため、pub が必要になる
            if plugin_option.include?("callback") then
                file.print "\tpub #{snake_case(callport.get_name.to_s)}: &'a "
            else
                file.print "\t#{snake_case(callport.get_name.to_s)}: &'a "
            end

            if check_gen_dyn_for_port(callport) == nil then
                file.print "#{alphabet},\n"
            else
                file.print "(#{check_gen_dyn_for_port(callport)} + Sync + Send),\n"
            end
        end
    end

    # セル構造体の変数フィールドの定義を生成
    def gen_rust_cell_structure_variable file, celltype
        if celltype.get_var_list.length != 0 then
            file.print "\tvariable: &'a TECSVariable<#{get_rust_celltype_name(celltype)}>,\n"
        end
    end
    
    # # セル構造体の ex_ctrl_ref フィールドの定義を生成
    # def gen_rust_cell_structure_ex_ctrl_ref file, celltype
    #     return if celltype.get_var_list.length == 0

    #     case check_gen_dyn_for_ex_ctrl_ref celltype
    #     when "dyn"
    #         file.print "\tex_ctrl_ref: &'a (dyn LockManager + Sync + Send),\n"
    #     when "dummy"
    #         # file.print "\tex_ctrl_ref: &'a TECSDummyMutexRef,\n"
    #     else
    #         case check_gen_dyn_or_mutex_or_semaphore_for_celltype celltype
    #         when "mutex"
    #             file.print "\tex_ctrl_ref: &'a TECSMutexRef<'a>,\n"
    #         when "semaphore"
    #             file.print "\tex_ctrl_ref: &'a TECSSemaphoreRef<'a>,\n"
    #         when "dyn"
    #             # TODO: ミューテックスとセマフォの呼び分け自体にも動的ディスパッチを使うのは議論の余地あり
    #             file.print "\tex_ctrl_ref: &'a (dyn LockManager + Sync + Send),\n"
    #         end
    #     end
    # end

    # Sync変数構造体の定義を生成
    # def gen_rust_sync_variable_structure file, celltype
    #     if celltype.get_var_list.length != 0 then
    #         file.print "pub struct Sync#{get_rust_celltype_name(celltype)}Var"
    #         celltype.get_var_list.each{ |var|
    #             var_type_name = var.get_type.get_type_str
    #             if check_lifetime_annotation_for_type(var_type_name) then
    #                 file.print "<'a>"
    #                 break
    #             end
    #         }
    #         file.print "{\n"
    #         file.print "\tunsafe_var: UnsafeCell<#{get_rust_celltype_name(celltype)}Var"
    #         celltype.get_var_list.each{ |var|
    #             var_type_name = var.get_type.get_type_str
    #             if check_lifetime_annotation_for_type(var_type_name) then
    #                 file.print "<'a>"
    #                 break
    #             end
    #         }
    #         file.print ">,\n"
    #         file.print "}\n\n"
    #     end
    # end

    # Syncトレイトの実装を生成
    # def gen_rust_impl_sync_trait_for_sync_variable_structure file, celltype
    #     return if celltype.get_var_list.length == 0

    #     file.print "unsafe impl"
    #     celltype.get_var_list.each{ |var|
    #         var_type_name = var.get_type.get_type_str
    #         if check_lifetime_annotation_for_type(var_type_name) then
    #             file.print "<'a>"
    #             break
    #         end
    #     }
    #     file.print " Sync for Sync#{get_rust_celltype_name(celltype)}Var"
    #     celltype.get_var_list.each{ |var|
    #         var_type_name = var.get_type.get_type_str
    #         if check_lifetime_annotation_for_type(var_type_name) then
    #             file.print "<'a>"
    #             break
    #         end
    #     }
    #     file.print " {}\n\n"
    # end

    # ロックガード構造体のヘッダーを生成
    def gen_rust_lock_guard_structure_header file, celltype, callport_list, use_jenerics_alphabet
        file.print "pub struct LockGuardFor#{get_rust_celltype_name(celltype)}"

        file.print "<'a"
        # use_jenerics_alphabet と callport_list の要素数が等しいことを前提としている
        callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
            if check_gen_dyn_for_port(callport) == nil then
                file.print ", #{alphabet}"
            end
        end
        file.print ">"

    end

    # ロックガード構造体の呼び口への参照の定義を生成
    def gen_rust_lock_guard_structure_callport file, callport_list, use_jenerics_alphabet
        callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
            if check_gen_dyn_for_port(callport) == nil then
                file.print "\tpub #{snake_case(callport.get_name.to_s)}: &'a #{alphabet},\n"
            else
                file.print "\tpub #{snake_case(callport.get_name.to_s)}: &'a (#{check_gen_dyn_for_port(callport)} + Sync + Send),\n"
            end
        end
    end

    # ロックガード構造体の属性への参照の定義を生成
    def gen_rust_lock_guard_structure_attribute file, celltype
        celltype.get_attribute_list.each{ |attr|
            if attr.is_omit? then
                next
            else
                file.print "\tpub #{attr.get_name.to_s}: "
                file.print "#{c_type_to_rust_type(attr.get_type)}"
                # str = c_type_to_rust_type(attr.get_type)
                # 属性や変数のフィールドに構造体がある場合は，ライフタイムを付与する必要がある
                # file.print "&'a #{str},\n"
            end
        }
    end

    # ロックガード構造体の変数への参照の定義を生成
    def gen_rust_lock_guard_structure_variable file, celltype
        if celltype.get_var_list.length != 0 then
            file.print "\tpub var: TECSVarGuard<'a, #{get_rust_celltype_name(celltype)}>,\n"
        end
    end

    # ロックガード構造体の定義を生成
    def gen_rust_lock_guard_structure file, celltype, callport_list, use_jenerics_alphabet

        if check_only_entryport_celltype(celltype) then
            return
        end

        gen_rust_lock_guard_structure_header file, celltype, callport_list, use_jenerics_alphabet

        gen_rust_cell_structure_jenerics file, callport_list, use_jenerics_alphabet

        file.print "{\n"

        gen_rust_lock_guard_structure_callport file, callport_list, use_jenerics_alphabet

        gen_rust_lock_guard_structure_attribute file, celltype

        gen_rust_lock_guard_structure_variable file, celltype

        gen_rust_cell_structure_ex_ctrl_ref file, celltype

        file.print "}\n\n"
        

        # return if celltype.get_var_list.length == 0

        # case check_gen_dyn_for_ex_ctrl_ref celltype
        # when "dyn"
        #     file.print "pub struct LockGuardFor#{get_rust_celltype_name(celltype)}<'a>{\n"
        #     file.print "\tex_ctrl_ref: &'a (dyn LockManager + Sync + Send),\n"
        # when "dummy"
        #     return
        # else
        #     file.print "pub struct LockGuardFor#{get_rust_celltype_name(celltype)}<'a>{\n"
        #     # セマフォを適用できるかを判断する
        #     case check_gen_dyn_or_mutex_or_semaphore_for_celltype celltype
        #     when "mutex"
        #         file.print "\tex_ctrl_ref: &'a TECSMutexRef<'a>,\n"
        #     when "semaphore"
        #         file.print "\tex_ctrl_ref: &'a TECSSemaphoreRef<'a>,\n"
        #     when "dyn"
        #         file.print "\tex_ctrl_ref: &'a (dyn LockManager + Sync + Send),\n"
        #     end
        # end

        # file.print "}\n\n"

    end

    def gen_rust_get_cell_ref file, celltype, callport_list, use_jenerics_alphabet
        # セルタイプに受け口がない場合は，生成しない
        # 受け口がないならば，get_cell_ref 関数が呼ばれることは現状無いため
        life_time_declare = false
        celltype.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then
                jenerics_flag = true
                file.print "impl"
                if check_only_entryport_celltype(celltype) then
                else
                    # check_only_entryport_celltype では，dyn な呼び口を判定していないため，ここで判定する
                    celltype.get_port_list.each{ |port|
                        if check_gen_dyn_for_port(port) == nil || use_jenerics_alphabet.length != 0 then
                            file.print "<"
                        end
                        break
                    }
                end
                # ライフタイムアノテーションの生成部
                # TODO：ライフタイムについては，もう少し厳格にする必要がある
                celltype.get_var_list.each{ |var|
                    # ライフタイムアノテーションが必要な型が変数にあるかどうかを判断
                    var_type_name = var.get_type.get_type_str
                    if check_lifetime_annotation_for_type(var_type_name) then
                        file.print "'a"
                        life_time_declare = true
                        break
                    end
                }

                if use_jenerics_alphabet.length != 0 && life_time_declare == true then
                    file.print ", "
                end

                # impl のジェネリクスを生成
                callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
                    if check_gen_dyn_for_port(callport) == nil then
                        if jenerics_flag then
                            jenerics_flag = false
                            file.print "#{alphabet}: #{get_rust_signature_name(callport.get_signature)}"
                        else
                            file.print ", #{alphabet}: #{get_rust_signature_name(callport.get_signature)}"
                        end
                    end
                end
                if check_only_entryport_celltype(celltype) then
                else
                    # check_only_entryport_celltype では，dyn な呼び口を判定していないため，ここで判定する
                    celltype.get_port_list.each{ |port|
                        if check_gen_dyn_for_port(port) == nil || use_jenerics_alphabet.length != 0 then
                            file.print ">"
                        end
                        break
                    }
                end

                # impl する型を生成
                file.print " #{get_rust_celltype_name(celltype)}"
                if check_only_entryport_celltype(celltype) then
                else
                    if check_lifetime_annotation_for_celltype_structure(celltype, callport_list) then
                        file.print "<'_"

                        callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
                            if check_gen_dyn_for_port(callport) == nil then
                                file.print ", #{alphabet}"
                            end
                        end
                        file.print ">"
                    end
                end
                file.print " {\n"
                # インライン化
                # if port.is_inline? then
                    file.print "\t#[inline]\n"
                # end
                # get_cell_ref 関数の定義を生成
                # TODO: ここのライフタイムの生成は、何かしら分岐が必要かも
                file.print "\tpub fn get_cell_ref<'b>"
                # ライフタイムアノテーションの生成部
                # TODO：ライフタイムについては，もう少し厳格にする必要がある
                # celltype.get_var_list.each{ |var|
                #     var_type_name = var.get_type.get_type_str
                #     if check_lifetime_annotation_for_type(var_type_name) && life_time_declare == false then
                #         file.print "<'a>"
                #         break
                #     end
                # }
                file.print "(&'a self, node: &'b mut MCSNode<#{get_rust_celltype_name(celltype)}>) -> "
                file.print "LockGuardFor#{get_rust_celltype_name(celltype)}"

                # TECS/Rust において、dyn な呼び口は、ジェネリクス参照ではなくトレイトオブジェクトへの参照として表現される
                # そのため、use_jenerics_alphabet にトレイトオブジェクトが入っている場合は、その生成をスキップする
                # セルタイプ構造体にライフタイムアノテーションが必要かどうか判定する(必要 -> 呼び口を持っている)
                # TODO: ライフタイムアノテーションの判定は厳格にする必要がある
                if check_lifetime_annotation_for_celltype_structure(celltype, callport_list) then
                    file.print "<'_"
                    # use_jenerics_alphabet と callport_list の要素数が等しいことを前提としている
                    callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
                        if check_gen_dyn_for_port(callport) == nil then
                            file.print ", #{alphabet}"
                        end
                    end
                    file.print ">"
                end

                file.print "\n\twhere\n"
                file.print "\t'b: 'a,\n"

                file.print " {\n"

                lock_guard_filed_name = []
                lock_guard_field_value = []

                callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
                    lock_guard_filed_name.push("#{snake_case(callport.get_name.to_s)}")
                    lock_guard_field_value.push("self.#{snake_case(callport.get_name.to_s)}")
                end

                celltype.get_attribute_list.each do |attr|
                    if attr.is_omit? then
                        next
                    end
                    lock_guard_filed_name.push(attr.get_name)
                    lock_guard_field_value.push("&self.#{attr.get_name}")
                end

                if celltype.get_var_list.length != 0 then
                    lock_guard_filed_name.push("var")
                    lock_guard_field_value.push("self.variable.lock(node)")
                end

                file.print "\t\tLockGuardFor#{get_rust_celltype_name(celltype)} {\n"

                lock_guard_filed_name.each_with_index do |field_name, index|
                    file.print "\t\t\t#{field_name}: #{lock_guard_field_value[index]},\n"
                end
                
                file.print "\t\t}"
                
                
                file.print"\n\t}\n}\n"
                # get_cell_ref 関数を生成するのは1回だけでいいため，break する
                break

            end # if port.get_port_type == :ENTRY then
        } # celltype.get_port_list.each
    end

    # ex_ctrl_ref フィールドの初期化を生成
    # def gen_rust_cell_structure_ex_ctrl_ref_initialize file, celltype, cell
    #     return if celltype.get_var_list.length == 0

    #     result = check_gen_dyn_for_ex_ctrl_ref celltype
    #     return if result == "dummy"

    #     case check_exclusive_control_for_cell cell
    #     when true
    #         file.print "\tex_ctrl_ref: &#{cell.get_global_name.to_s.upcase}_EX_CTRL_REF,\n"
    #     else
    #         file.print "\tex_ctrl_ref: &DUMMY_EX_CTRL_REF,\n"
    #     end
    # end

    # 変数構造体と TECSVariable enum の初期化を生成
    def gen_rust_variable_structure_initialize file, cell
        if @celltype.get_var_list.length != 0 then
            file.print "static #{cell.get_global_name.to_s.upcase}VAR: TECSVariable<#{get_rust_celltype_name(cell.get_celltype)}> = TECSVariable::"

            # セルに排他制御が必要かどうか
            if check_exclusive_control_for_cell(cell) == "mutex" then
                file.print "Mutexed(Mutex::new(\n"
            else
                file.print "Raw(TECSSyncVar { unsafe_var: UnsafeCell::new(\n"
            end

            file.print "\t#{get_rust_celltype_name(cell.get_celltype)} {\n"
            gen_comments_safe_reason file, cell
            # 変数構造体のフィールドの初期化を生成
            @celltype.get_var_list.each{ |var|
                var_array = var.get_initializer
                # 変数が配列であるときに対応
                if var_array.is_a?(Array) then
                    file.print "\t\t#{var.get_name}: ["
                    var_array.each{ |var_array_item|
                        if var_array_item == var_array.last then
                            file.print "#{var_array_item.to_s}"
                        else
                            file.print "#{var_array_item.to_s}, "
                        end
                    }
                    file.print "],\n"
                else
                    file.print "\t\t#{var.get_name}: #{var.get_initializer},\n"
                end
            }

            if check_exclusive_control_for_cell(cell) == "mutex" then
                file.print "\t}\n"
                file.print "));\n"
            else
                file.print "\t}),\n"
                file.print "});\n\n"
            end
        end
    end

    def gen_comments_safe_reason file, cell
        case check_exclusive_control_for_cell cell
        when true
            file.print "/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.\n"
        else
            case check_multiple_accessed_for_cell cell
            when true
                # root に近いコンポーネントで排他制御を行っている場合
                file.print "/// This UnsafeCell is accessed by multiple tasks, but is secure because it is accessed exclusively, with exclusive control applied to the component closest to root.\n"
            else
                file.print "/// This UnsafeCell is safe because it is only accessed by one task due to the call flow and component structure of TECS.\n"
            end
        end
    end

    # ex_ctrl_ref の初期化を生成
    # def gen_rust_ex_ctrl_ref_initialize file, cell
    #     return if @celltype.get_var_list.length == 0
    #     multiple = check_exclusive_control_for_cell cell
    #     if multiple then
    #         file.print "#[link_section = \".rodata\"]\n"
    #         case check_gen_which_ex_ctrl cell
    #         when "semaphore"
    #             file.print "pub static #{cell.get_global_name.to_s.upcase}_EX_CTRL_REF: TECSSemaphoreRef = TECSSemaphoreRef{\n"
    #             file.print "\tinner: unsafe{SemaphoreRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_#{@@ex_ctrl_ref_id}).unwrap())},\n"
    #             file.print "};\n\n"
    #             gen_semaphore_static_api_for_configuration cell
    #         when "mutex"
    #             file.print "pub static #{cell.get_global_name.to_s.upcase}_EX_CTRL_REF: TECSMutexRef = TECSMutexRef{\n"
    #             file.print "\tinner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_#{@@ex_ctrl_ref_id}).unwrap())},\n"
    #             file.print "};\n\n"
    #             gen_mutex_static_api_for_configuration cell
    #         end
    #     end
    # end

    # ロックガードに Drop トレイトを実装する
    # def gen_rust_impl_drop_for_lock_guard_structure file, celltype, callport_list, use_jenerics_alphabet
    #     return if celltype.get_var_list.length == 0

    #     result = check_gen_dyn_for_ex_ctrl_ref celltype
    #     return if result == "dummy"

    #     life_time_declare = false
    #     jenerics_flag = true

    #     file.print "impl"
    #     # celltype.get_var_list.each{ |var|
    #     #     var_type_name = var.get_type.get_type_str
    #     #     if check_lifetime_annotation_for_type(var_type_name) then
    #     #         file.print "<'a>"
    #     #         break
    #     #     end
    #     # }

    #     if check_only_entryport_celltype(celltype) then
    #     else
    #         # check_only_entryport_celltype では，dyn な呼び口を判定していないため，ここで判定する
    #         celltype.get_port_list.each{ |port|
    #             if check_gen_dyn_for_port(port) == nil || use_jenerics_alphabet.length != 0 then
    #                 file.print "<"
    #             end
    #             break
    #         }
    #     end
    #     # ライフタイムアノテーションの生成部
    #     # TODO：ライフタイムについては，もう少し厳格にする必要がある
    #     celltype.get_var_list.each{ |var|
    #         # ライフタイムアノテーションが必要な型が変数にあるかどうかを判断
    #         var_type_name = var.get_type.get_type_str
    #         if check_lifetime_annotation_for_type(var_type_name) then
    #             file.print "'a"
    #             life_time_declare = true
    #             break
    #         end
    #     }

    #     if use_jenerics_alphabet.length != 0 && life_time_declare == true then
    #         file.print ", "
    #     end

    #     # impl のジェネリクスを生成
    #     callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
    #         if check_gen_dyn_for_port(callport) == nil then
    #             if jenerics_flag then
    #                 jenerics_flag = false
    #                 file.print "#{alphabet}: #{get_rust_signature_name(callport.get_signature)}"
    #             else
    #                 file.print ", #{alphabet}: #{get_rust_signature_name(callport.get_signature)}"
    #             end
    #         end
    #     end
    #     if check_only_entryport_celltype(celltype) then
    #     else
    #         # check_only_entryport_celltype では，dyn な呼び口を判定していないため，ここで判定する
    #         celltype.get_port_list.each{ |port|
    #             if check_gen_dyn_for_port(port) == nil || use_jenerics_alphabet.length != 0 then
    #                 file.print ">"
    #             end
    #             break
    #         }
    #     end


    #     file.print " Drop for LockGuardFor#{get_rust_celltype_name(celltype)}"
    #     # celltype.get_var_list.each{ |var|
    #     #     var_type_name = var.get_type.get_type_str
    #     #     if check_lifetime_annotation_for_type(var_type_name) then
    #     #         file.print "<'a>"
    #     #         break
    #     #     end
    #     # }
    #     if check_lifetime_annotation_for_celltype_structure(celltype, callport_list) then
    #         file.print "<'_"
    #         # use_jenerics_alphabet と callport_list の要素数が等しいことを前提としている
    #         callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
    #             if check_gen_dyn_for_port(callport) == nil then
    #                 file.print ", #{alphabet}"
    #             end
    #         end
    #         file.print ">"
    #     end

    #     file.print " {\n"
    #     file.print "\tfn drop(&mut self){\n"
    #     file.print "\t\tself.ex_ctrl_ref.unlock();\n"
    #     file.print "\t}\n"
    #     file.print "}\n\n"
    # end

# 2025/07/04 ここまで

    # セルタイプに受け口がある場合，受け口関数を生成する
    def gen_rust_entryport_function file, celltype, callport_list
        # セルタイプに受け口がある場合，impl を生成する
        celltype.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then
                sig = port.get_signature

                file.print "impl #{camel_case(snake_case(port.get_signature.get_global_name.to_s))} for #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(celltype)}"
                file.print "<'_>"
                file.print "{\n\n"

                sig_param_str_list, _, lifetime_flag = get_sig_param_str sig

                # 空の関数を生成
                sig.get_function_head_array.each{ |func_head|
                    # 関数のインライン化
                    if port.is_inline? then
                        file.print "\t#[inline]\n"
                    end
                    file.print "\tfn #{get_rust_function_name(func_head)}"
                    if lifetime_flag then
                        file.print "<'a>"
                    end
                    file.print"(&'static self"
                    # param_num と sig_param_str_list の要素数が等しいことを前提としている
                    param_num = func_head.get_paramlist.get_items.size
                    param_num.times do
                        current_param = sig_param_str_list.shift
                        if current_param == "ignore" then
                            next
                        end
                        file.print "#{current_param}"
                    end
                    file.print ") "

                    # 返り値の型がunknown,つまりvoidのときは，-> を生成しない
                    if c_type_to_rust_type(func_head.get_return_type) != "unknown" then
                        file.print "-> #{c_type_to_rust_type(func_head.get_return_type)}"
                    end

                    file.print "{\n"

                    if check_only_entryport_celltype(celltype) then
                    else
                        # # get_cell_ref 関数の呼び出しを生成
                        # file.print "\t\tlet "

                        # # get_cell_ref 関数の返り値を格納するタプルを生成
                        # tuple_name_list = []
                        # callport_list.each{ |callport|
                        #     tuple_name_list.push "#{snake_case(callport.get_name.to_s)}"
                        # }
                        # celltype.get_attribute_list.each{ |attr|
                        #     if attr.is_omit? then
                        #         next
                        #     end
                        #     tuple_name_list.push "#{attr.get_name.to_s}"
                        # }
                        # if celltype.get_var_list.length != 0 then
                        #     tuple_name_list.push "var"
                        #     tuple_name_list.push "_lg"
                        # end

                        # if tuple_name_list.length != 1 then
                        #     file.print "("
                        # end

                        # tuple_name_list.each_with_index do |tuple_name, index|
                        #     if index == tuple_name_list.length - 1 then
                        #         file.print "#{tuple_name}"
                        #         break
                        #     end
                        #     file.print "#{tuple_name}, "
                        # end

                        # if tuple_name_list.length != 1 then
                        #     file.print ")"
                        # end

                        # file.print " = self.cell.get_cell_ref();\n"

                        # ロックガードで覆う場合の生成
                        file.print "\t\tlet lg = self.cell.get_cell_ref();\n"
                    end
                    file.print "\n"
                    file.print"\t}\n"
                }

                file.print "}\n\n"

            else
            end
        }
    end

    # Cargo の新規プロジェクトを作成する
    def cargo_new_project path
        super(path)

        gen_config_toml path

    end

    # Cargo.toml の設定を変更する
    # def change_cargo_toml path
    #     # cargo_toml_path = "#{path}/Cargo.toml"

    #     # # TODO: asp3 か fmp3 かは、何かしらで判断する必要がある
    #     # itron_rs_depenence = "itron = { version = \"= 0.1.9\", features = [\"asp3\", \"nightly\", \"unstable\"] }"

    #     # File.open(cargo_toml_path, "a") do |file|
    #     #     file.puts itron_rs_depenence
    #     #     file.puts ""
    #     # end

    #     super(path)
    # end

    # cargo.toml の設定を生成する
    # def gen_config_toml path
    #     config_toml_dir = "#{path}/.cargo"
    #     comfig_toml_path = "#{config_toml_dir}/config.toml"

    #     return if Dir.exist?(config_toml_dir)

    #     Dir.mkdir(config_toml_dir)
    #     File.open(comfig_toml_path, "w") do |file|
    #         file.puts "[build]"
    #         file.puts "# target = \"thumbv7em-none-eabihf\"     # Cortex-M4F and Cortex-M7F (with FPU) (e.g., Spike-rt)"
    #         file.puts "# target = \"armv7a-none-eabi\"          # Bare Armv7-A (e.g., Zynq-7000 (Xilinx))"
    #     end
    # end

    # 他のRustプラグインで生成したい RUST_PLUGIN_TECSGEN_SRCS の要素
    # def gen_extra_rust_plugin_tecsgen_srcs_for_makefile makefile
    #     makefile.print( "\t$(TECS_RUST_SRC_DIR)/kernel_cfg.rs \\\n" )
    #     makefile.print( "\t$(TECS_RUST_SRC_DIR)/tecs_ex_ctrl.rs \\\n" )
    #     makefile.print( "\t$(TECS_RUST_SRC_DIR)/tecs_print.rs \\\n" )
    # end

    # tecs_mutex.rs を生成する
    def gen_tecs_variable_rs
        contents = <<~'EOS'
use core::cell::UnsafeCell;
use awkernel_lib::sync::mutex::{Mutex, MCSNode, LockGuard};

pub struct TECSSyncVar<T>{
    pub unsafe_var: UnsafeCell<T>,
}

unsafe impl<T> Sync for TECSSyncVar<T> {}

pub enum TECSVariable<T: core::marker::Send>{
    Mutexed(Mutex<T>),
    Raw(TECSSyncVar<T>),
}

impl<'a, T: core::marker::Send> TECSVariable<T>{
    #[inline]
	pub fn lock(&'a self, node: &'a mut MCSNode<T>) -> TECSVarGuard<'a, T>{
		match self {
            TECSVariable::Mutexed(v) => TECSVarGuard::Mutexed(v.lock(node)),
            TECSVariable::Raw(v) => TECSVarGuard::Dummy(v.unsafe_var.get()),
		}
	}
}

pub enum TECSVarGuard<'a, T: core::marker::Send>{
    Mutexed(LockGuard<'a, T>),
    Dummy(*mut T),
}

impl<'a, T: core::marker::Send> core::ops::Deref for TECSVarGuard<'a, T> {
    type Target = T;
    #[inline]
    fn deref(&self) -> &Self::Target {
        match self {
            TECSVarGuard::Mutexed(g)  => &*g,
            TECSVarGuard::Dummy(p) => unsafe { &**p },
        }
    }
}

impl<'a, T: core::marker::Send> core::ops::DerefMut for TECSVarGuard<'a, T> {
    #[inline]
    fn deref_mut(&mut self) -> &mut Self::Target {
        match self {
            TECSVarGuard::Mutexed(g)  => &mut *g,
            TECSVarGuard::Dummy(p) => unsafe { &mut **p },
        }
    }
}
            EOS

        variable_file = CFile.open( "#{$gen}/tecs_variable.rs", "w" )
        variable_file.print contents
        variable_file.close

        if File.exist?("#{@@cargo_path}}/tecs_variable.rs") == false then
            copy_gen_files_to_cargo "tecs_variable.rs"
        end
    end

    # syslog の Rust ラップである print.rs を生成する
    # カーネルによって型などが異なるため、それぞれのプラグインで実装する
    def gen_tecs_print_rs

    end

    #=== tCelltype_factory.h に挿入するコードを生成する
    # file 以外の他のファイルにファクトリコードを生成してもよい
    # セルタイププラグインが指定されたセルタイプのみ呼び出される
    def gen_factory file

        # temp = File.readlines("#{@@cargo_path}/src/lib.rs")
        # puts temp

        # @celltype.get_cell_list.each{ |cell|
        #     gen_mod_in_lib_rs_for_cell cell
        # }

        super(file)

        # TODO: 必要なときにのみ生成するようにする
        gen_tecs_ex_ctrl_rs

        # TODO: 必要なときにのみ生成するようにする
        # gen_tecs_mutex_rs

        # TODO: 必要なときにのみ生成するようにする
        # gen_tecs_semaphore_rs

        gen_tecs_print_rs

        copy_gen_files_to_cargo "kernel_cfg.rs"
    end

end
