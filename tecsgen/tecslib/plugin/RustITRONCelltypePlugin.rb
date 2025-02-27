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
class RustITRONCelltypePlugin < RustGenCelltypePlugin
    CLASS_NAME_SUFFIX = ""
    @@b_signature_header_generated = false
    @@module_generated = false
    @@arm_none_eabi_nm_gen = false
    @@kernel_cfg_rs_gen = false
    @@rust_task_func_list = []
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

    # セルタイプ名から，カーネルオブジェクトかどうか判断し，Ref型文字列に変換する
    def get_itronrs_kernel_obj_ref_str
        plugin_option = @plugin_arg_str.split(",").map(&:strip)
        if plugin_option.include?("TASK") then
            return "TaskRef"
        elsif plugin_option.include?("SEMAPHORE") then
            return "SemaphoreRef"
        elsif plugin_option.include?("EVENTFLAG") then
            return "EventflagRef"
        elsif plugin_option.include?("DATAQUEUE") then
            return "DataqueueRef"
        elsif plugin_option.include?("MUTEX") then
            return "MutexRef"
        else
            return "unknown"
        end
    end

    def gen_mod_in_main_lib_rs_for_celltype celltype
        plugin_option = @plugin_arg_str.split(",").map(&:strip)

        file_name = check_option_main_or_lib

        if file_name != nil then
            # TODO: 本当に排他制御が必要なときのみ、排他制御モジュールを生成するようにする
            write_list = ["#![no_std]", "#![feature(const_option)]", "mod kernel_cfg;", "mod tecs_ex_ctrl;", "mod tecs_print;"]
            # File.write("#{$gen}/#{file_name}.rs", "") unless File.exist?("#{$gen}/#{file_name}.rs")
            tempfile = File.read("#{$gen}/#{file_name}.rs")

            write_list.each do |write|
                if tempfile.include?(write) then
                    next
                else
                    tempfile << write + "\n"
                end
            end
            File.write("#{$gen}/#{file_name}.rs", tempfile)
        end

        if plugin_option.include?("TASK") then
            gen_task_func_definition file_name, celltype
        end

        super(celltype)


    end

    def gen_task_func_definition file_option, celltype
        file = File.read("#{$gen}/#{file_option}.rs")

        # 一番最初のタスク関数生成の時だけ、以下のパニックハンドラと、二つのuse文を追加する
        gen_panic_handler_in_main_lib_rs file

        if !file.include?("use crate::" + snake_case(celltype.get_global_name.to_s) + "::*;") then
            file << "\nuse crate::" + snake_case(celltype.get_global_name.to_s) + "::*;\n"
        end

        if !file.include?("use s_task_body::*;") then
            file << "use s_task_body::*;\n"
        end
        
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

    def gen_panic_handler_in_main_lib_rs file
        search_code = <<~CODE

#[panic_handler]
fn panic(_panic: &core::panic::PanicInfo<'_>) -> ! {
    loop {}
}
CODE
        if !file.include?(search_code) then
            file << search_code
        end
    end

    # ビルドのためのダミーオブジェクトIDを生成する
    def add_dummy_id_to_kernel_cfg_rs name, id

        # 初回のみファイルを生成する
        if @@kernel_cfg_rs_gen == false then
            File.write("#{$gen}/kernel_cfg.rs", "")
            @@kernel_cfg_rs_gen = true
        end

        kernel_cfg_rs = File.open("#{$gen}/kernel_cfg.rs", "a")

        if id > 0 then
            kernel_cfg_rs.print "pub const #{name}: i32 = #{id};\t//Dummy id\n"
        else
            kernel_cfg_rs.print "pub const #{name}: i32 = 1;\t//Dummy id\n"
        end
        kernel_cfg_rs.close
    end
    
    # 引数の文字列が、ITRONクレートのカーネルオブジェクトへの参照型になっているかを追加判定する
    # TODO: リファクタリングの余地あり
    def check_lifetime_annotation_for_type str
        result = super(str)
        
        itron_rs_refs = [
            "TaskRef",
            "SemaphoreRef",
            "EventflagRef",
            "DataqueueRef",
            "MutexRef",
        ]

        match_found = itron_rs_refs.include?(str)

        return result || match_found

    end

    def gen_rust_tecs_h function_name

        @@rust_task_func_list.push("#{function_name}")

        rust_tecs_h = CFile.open( "#{$gen}/rust_tecs.h", "w")

        rust_tecs_h.print "\#ifndef RUST_TECS_H\n"
        rust_tecs_h.print "\#define RUST_TECS_H\n"
        rust_tecs_h.print "\#include <kernel.h>\n"
        rust_tecs_h.print "\n"

        @@rust_task_func_list.each{ |func|
            rust_tecs_h.print "extern void #{func}(intptr_t exinf);\n"
        }

        rust_tecs_h.print "\n"
        rust_tecs_h.print "#endif\n"

        rust_tecs_h.close
    end

    # RustASP3CelltypePlugin や RustFMP3CelltypePlugin などで、それぞれのタスクの静的APIを生成する
    def gen_task_static_api_for_configuration cell

    end

    def gen_use_mutex file

        case check_gen_dyn_or_mutex_or_semaphore_for_celltype @celltype
        when "mutex"
            file.print "use itron::mutex::MutexRef;\n"
        when "semaphore"
            file.print "use itron::semaphore::SemaphoreRef;\n"
        when "dyn" # TODO: ダミー+セマフォorミューテックスのケースでは、片方の生成だけでいい
            file.print "use itron::mutex::MutexRef;\n"
            file.print "use itron::semaphore::SemaphoreRef;\n"
        end

        # file.print "use crate::tecs_mutex::*;\n"
        file.print "use crate::tecs_ex_ctrl::*;\n" # TODO: 本当に排他制御が必要なときのみ生成するようにする
        file.print "use core::cell::UnsafeCell;\n"
        file.print "use core::num::NonZeroI32;\n"
        file.print "use crate::kernel_cfg::*;\n"
    end

    def gen_use_header file
        kernel_obj = get_itronrs_kernel_obj_ref_str
        if kernel_obj != "unknown" then
            file.print "use itron::#{kernel_obj[0..-4].downcase}::#{kernel_obj};\n"
            file.print "use core::num::NonZeroI32;\n"
            file.print "use crate::kernel_cfg::*;\n"
        end
        
        super(file)
    end

    # セル構造体の呼び口フィールドの定義を生成
    def gen_rust_cell_structure_callport file, callport_list, use_jenerics_alphabet
        task_flag = false
        task_flag = true if get_itronrs_kernel_obj_ref_str == "TaskRef"

        callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
            # TODO: tTaskRs がタスクオブジェクトであることを前提としている
            if task_flag == true && snake_case(callport.get_name.to_s) == "c_task_body" then
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
            file.print "\tvariable: &'a Sync#{get_rust_celltype_name(celltype)}Var"
            celltype.get_var_list.each{ |var|
                var_type_name = var.get_type.get_type_str
                if check_lifetime_annotation_for_type(var_type_name) then
                    file.print "<'a>"
                    break
                end
            }
            file.print ",\n"
        end
    end

    
    # セル構造体の ex_ctrl_ref フィールドの定義を生成
    def gen_rust_cell_structure_ex_ctrl_ref file, celltype
        return if celltype.get_var_list.length == 0

        case check_gen_dyn_for_ex_ctrl_ref celltype
        when "dyn"
            file.print "\tex_ctrl_ref: &'a (dyn LockManager + Sync + Send),\n"
        when "dummy"
            # file.print "\tex_ctrl_ref: &'a TECSDummyMutexRef,\n"
        else
            case check_gen_dyn_or_mutex_or_semaphore_for_celltype celltype
            when "mutex"
                file.print "\tex_ctrl_ref: &'a TECSMutexRef<'a>,\n"
            when "semaphore"
                file.print "\tex_ctrl_ref: &'a TECSSemaphoreRef<'a>,\n"
            when "dyn"
                # TODO: ミューテックスとセマフォの呼び分け自体にも動的ディスパッチを使うのは議論の余地あり
                file.print "\tex_ctrl_ref: &'a (dyn LockManager + Sync + Send),\n"
            end
        end
    end

    # ミューテックスを適用するセルとセマフォを適用するセルが混在するセルタイプかどうかを判断する
    def check_gen_dyn_or_mutex_or_semaphore_for_celltype celltype
        check_semaphore = []

        celltype.get_cell_list.each{ |cell|
            check_semaphore.push(check_gen_which_ex_ctrl cell).uniq!
        }

        # 動的ディスパッチを使うのは以下のケース
        # ・セマフォを適用するセルとミューテックスを適用するセルが混在する場合
        # ・セマフォを適用するセルとダミーを利用するセルが混在する場合
        # ・ミューテックスを適用するセルとダミーを利用するセルが混在する場合
        if check_semaphore.length >= 2 then
            return "dyn"
        end

        if check_semaphore.length == 1 then
            return check_semaphore.first
        end
    end

    # セルの排他制御をセマフォにするかどうかを判断する
    # TODO: chg_pri があるか無いかを判定する必要がある
    def check_gen_which_ex_ctrl cell
        # JSONファイルがパースされていない場合は，セマフォにしない
        if @@json_parse_result.length == 0 then
            puts "JSONファイルがパースされていません"
            return "mutex"
        end

        celltype = cell.get_celltype.get_global_name.to_s
        if @@json_parse_result[cell.get_global_name.to_s]["Celltype"] == celltype then
            # 優先度が同じタスクからのみアクセスされる場合は，セマフォにする
            if @@json_parse_result[cell.get_global_name.to_s]["ExclusiveControl"] == "true" && @@json_parse_result[cell.get_global_name.to_s]["PriorityList"].length == 1 then
                # ターゲットトリプルを取得
                target_triple = extract_target_triple @@cargo_path

                # chg_pri がある場合は，ミューテックスにする
                if target_triple != nil && check_call_chg_pri(@@cargo_path, target_triple) == true then
                    return "mutex"
                end
                return "semaphore"

            elsif @@json_parse_result[cell.get_global_name.to_s]["ExclusiveControl"] == "true" then
                return "mutex"
            end
        end

        return "none"
    end

    # Sync変数構造体の定義を生成
    def gen_rust_sync_variable_structure file, celltype
        if celltype.get_var_list.length != 0 then
            file.print "pub struct Sync#{get_rust_celltype_name(celltype)}Var"
            celltype.get_var_list.each{ |var|
                var_type_name = var.get_type.get_type_str
                if check_lifetime_annotation_for_type(var_type_name) then
                    file.print "<'a>"
                    break
                end
            }
            file.print "{\n"
            file.print "\tunsafe_var: UnsafeCell<#{get_rust_celltype_name(celltype)}Var"
            celltype.get_var_list.each{ |var|
                var_type_name = var.get_type.get_type_str
                if check_lifetime_annotation_for_type(var_type_name) then
                    file.print "<'a>"
                    break
                end
            }
            file.print ">,\n"
            file.print "}\n\n"
        end
    end

    # Syncトレイトの実装を生成
    def gen_rust_impl_sync_trait_for_sync_variable_structure file, celltype
        return if celltype.get_var_list.length == 0

        file.print "unsafe impl"
        celltype.get_var_list.each{ |var|
            var_type_name = var.get_type.get_type_str
            if check_lifetime_annotation_for_type(var_type_name) then
                file.print "<'a>"
                break
            end
        }
        file.print " Sync for Sync#{get_rust_celltype_name(celltype)}Var"
        celltype.get_var_list.each{ |var|
            var_type_name = var.get_type.get_type_str
            if check_lifetime_annotation_for_type(var_type_name) then
                file.print "<'a>"
                break
            end
        }
        file.print " {}\n\n"
    end

    # ロックガード構造体の定義を生成
    def gen_rust_lock_guard_structure file, celltype
        return if celltype.get_var_list.length == 0


        case check_gen_dyn_for_ex_ctrl_ref celltype
        when "dyn"
            file.print "pub struct LockGuardFor#{get_rust_celltype_name(celltype)}<'a>{\n"
            file.print "\tex_ctrl_ref: &'a (dyn LockManager + Sync + Send),\n"
        when "dummy"
            return
        else
            file.print "pub struct LockGuardFor#{get_rust_celltype_name(celltype)}<'a>{\n"
            # セマフォを適用できるかを判断する
            case check_gen_dyn_or_mutex_or_semaphore_for_celltype celltype
            when "mutex"
                file.print "\tex_ctrl_ref: &'a TECSMutexRef<'a>,\n"
            when "semaphore"
                file.print "\tex_ctrl_ref: &'a TECSSemaphoreRef<'a>,\n"
            when "dyn"
                file.print "\tex_ctrl_ref: &'a (dyn LockManager + Sync + Send),\n"
            end
        end

        file.print "}\n\n"

    end

    def creat_itron_rs_use cell
        # 書き込んでいるファイルの行を取得する
        global_file_name = snake_case(cell.get_global_name.to_s)
        lines = File.readlines("#{$gen}/#{global_file_name}.rs")
        # use 文を追加する
        lines.insert(0, "use crate::kernel_obj_ref::*;  //特別な生成部\n")
        lines.insert(0, "use itron::task::TaskRef;  //特別な生成部\n")
        lines.insert(0, "use itron::abi::*;  //特別な生成部\n")
        File.open("#{$gen}/#{global_file_name}.rs", 'w') do |file|
            file.puts lines
        end
        # file.close
    end

    # セル構造体の属性フィールドの定義を生成
    def gen_rust_cell_structure_attribute file, celltype
        celltype.get_attribute_list.each{ |attr|
            if attr.is_omit? then
                next
            else
                file.print "\t#{attr.get_name.to_s}: "
                # file.print "#{c_type_to_rust_type(attr.get_type)}"
                str = c_type_to_rust_type(attr.get_type)
                # 属性や変数のフィールドに構造体がある場合は，ライフタイムを付与する必要がある
                # itron-rsオブジェクトに対する，特別な生成
                # ライフタイムを付与
                case str
                when "TaskRef"
                    str = "TaskRef<'a>"
                when "SemaphoreRef"
                    str = "SemaphoreRef<'a>"
                when "EventflagRef"
                    str = "EventflagRef<'a>"
                when "DataqueueRef"
                    str = "DataqueueRef<'a>"
                when "MutexRef"
                    str = "MutexRef<'a>"
                end
                file.print "#{str},\n"
            end
        }
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
                if port.is_inline? then
                    file.print "\t#[inline]\n"
                end
                # get_cell_ref 関数の定義を生成
                file.print "\tpub fn get_cell_ref"
                # ライフタイムアノテーションの生成部
                # TODO：ライフタイムについては，もう少し厳格にする必要がある
                celltype.get_var_list.each{ |var|
                    var_type_name = var.get_type.get_type_str
                    if check_lifetime_annotation_for_type(var_type_name) && life_time_declare == false then
                        file.print "<'a>"
                        break
                    end
                }
                file.print "(&'static self) -> "

                # 返り値のタプル型の要素をまとめるための配列
                return_tuple_type_list = []
                return_tuple_list = []

                # 呼び口をタプルの配列に追加
                callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
                    return_tuple_type_list.push("&'static #{alphabet}")
                    return_tuple_list.push("self.#{snake_case(callport.get_name.to_s)}")
                end

                # 属性をタプルの配列に追加
                celltype.get_attribute_list.each{ |attr|
                    if attr.is_omit? then
                        next
                    end
                    return_tuple_type_list.push("&'static #{c_type_to_rust_type(attr.get_type)}")
                    return_tuple_list.push("&self.#{attr.get_name.to_s}")
                }

                # 変数をタプルの配列に追加
                if celltype.get_var_list.length != 0 then
                    return_tuple_type_list.push("&'static mut #{get_rust_celltype_name(celltype)}Var")
                    # celltype.get_var_list.each{ |var|
                    #     var_type_name = var.get_type.get_type_str
                    #     if check_lifetime_annotation_for_type(var_type_name) then
                    #         return_tuple_type_list[-1].concat("<'a>")
                    #         break
                    #     end
                    # }
                    # return_tuple_type_list[-1].concat(">")
                    return_tuple_list.push("unsafe{&mut *self.variable.unsafe_var.get()}")
                end

                # ロックガードを配列に追加
                # TODO: 変数が無い、もしくはダミーだけの時にはロックガードを生成しなくてもいいかも。しかし、get_cell_ref の返り値の数はそろえる必要がある
                if celltype.get_var_list.length != 0 then
                    result = check_gen_dyn_for_ex_ctrl_ref celltype
                    if result == "dummy" then
                        return_tuple_type_list.push("&TECSDummyLockGuard")
                        return_tuple_list.push("&DUMMY_LOCK_GUARD")
                    else
                        return_tuple_type_list.push("LockGuardFor#{get_rust_celltype_name(celltype)}")
                        return_tuple_list.push("LockGuardFor#{get_rust_celltype_name(celltype)}{\n\t\t\t\tex_ctrl_ref: self.ex_ctrl_ref,\n\t\t\t}")
                    end
                end

                if return_tuple_type_list.length != 1 then
                    file.print "("
                end

                # 返り値のタプル型を生成
                return_tuple_type_list.each_with_index do |return_tuple_type, index|
                    if index == return_tuple_type_list.length - 1 then
                        file.print "#{return_tuple_type}"
                        break
                    end
                    file.print "#{return_tuple_type}, "
                end

                if return_tuple_type_list.length != 1 then
                    file.print ")"
                end
                file.print " {\n"

                if celltype.get_var_list.length != 0 then
                    result = check_gen_dyn_for_ex_ctrl_ref celltype
                    if result != "dummy" then
                        file.print "\t\tself.ex_ctrl_ref.lock();\n"
                    end
                end

                file.print "\t\t"
                
                if return_tuple_list.length != 1 then
                    file.print "(\n"
                end

                # 返り値のタプルを生成
                return_tuple_list.each_with_index do |return_tuple, index|
                    if return_tuple_list.length == 1 then
                        file.print "#{return_tuple}"
                        break
                    end

                    if index == return_tuple_list.length - 1 then
                        file.print "\t\t\t#{return_tuple}\n"
                        break
                    end
                    file.print "\t\t\t#{return_tuple},\n"
                end

                if return_tuple_list.length != 1 then
                    file.print "\t\t)"
                end
                
                file.print"\n\t}\n}\n"
                # get_cell_ref 関数を生成するのは1回だけでいいため，break する
                break

            end # if port.get_port_type == :ENTRY then
        } # celltype.get_port_list.each
    end

    # ex_ctrl_ref フィールドの初期化を生成
    def gen_rust_cell_structure_ex_ctrl_ref_initialize file, celltype, cell
        return if celltype.get_var_list.length == 0

        result = check_gen_dyn_for_ex_ctrl_ref celltype
        return if result == "dummy"

        case check_exclusive_control_for_cell cell
        when true
            file.print "\tex_ctrl_ref: &#{cell.get_global_name.to_s.upcase}_EX_CTRL_REF,\n"
        else
            file.print "\tex_ctrl_ref: &DUMMY_EX_CTRL_REF,\n"
        end
    end

    # itron のコンフィグレーションファイルにミューテックス静的APIを生成する
    # RustASP3CelltypePlugin や RustFMP3CelltypePlugin などで、具体的な静的APIの生成を実装する
    def gen_mutex_static_api_for_configuration cell
        
    end

    # itron のコンフィグレーションファイルにセマフォ静的APIを生成する
    # RustASP3CelltypePlugin や RustFMP3CelltypePlugin などで、具体的な静的APIの生成を実装する
    def gen_semaphore_static_api_for_configuration cell

    end

    # セルのミューテックスオブジェクトの優先度上限値を取得する
    def get_ceiling_priority cell
        # JSONファイルがパースされていない場合は、優先度上限を 1 として返す
        if @@json_parse_result.length == 0 then
            return 1
        end

        # puts "@@json_parse_result: #{@@json_parse_result}"

        celltype = cell.get_celltype.get_global_name.to_s
        if @@json_parse_result[cell.get_global_name.to_s]["Celltype"] == celltype then
            if @@json_parse_result[cell.get_global_name.to_s]["ExclusiveControl"] == "true" && @@json_parse_result[cell.get_global_name.to_s]["PriorityList"].length != 0 then
                return @@json_parse_result[cell.get_global_name.to_s]["PriorityList"].min
            end
        end
        puts "Error: JSON file does not include #{cell.get_global_name.to_s}"
        return 1
    end

    # Sync変数構造体の初期化を生成
    def gen_rust_variable_structure_initialize file, cell
        if @celltype.get_var_list.length != 0 then
            file.print "pub static #{cell.get_global_name.to_s.upcase}VAR: Sync#{get_rust_celltype_name(cell.get_celltype)}Var = Sync#{get_rust_celltype_name(cell.get_celltype)}Var {\n"
            file.print "\t"
            gen_comments_safe_reason file, cell
            file.print "\tunsafe_var: UnsafeCell::new(#{get_rust_celltype_name(cell.get_celltype)}Var {\n"
            # 変数構造体のフィールドの初期化を生成
            @celltype.get_var_list.each{ |var|
                var_array = var.get_initializer
                # 属性が配列であるときに対応
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
            file.print "\t}),\n"
            file.print "};\n\n"
        end
    end

    def gen_comments_safe_reason file, cell
        case check_exclusive_control_for_cell cell
        when true
            case check_gen_which_ex_ctrl cell
            when "semaphore"
                file.print "/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the semaphore object.\n"
            when "mutex"
                file.print "/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.\n"
            end
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
    def gen_rust_ex_ctrl_ref_initialize file, cell
        return if @celltype.get_var_list.length == 0
        multiple = check_exclusive_control_for_cell cell
        if multiple then
            file.print "#[link_section = \".rodata\"]\n"
            case check_gen_which_ex_ctrl cell
            when "semaphore"
                file.print "pub static #{cell.get_global_name.to_s.upcase}_EX_CTRL_REF: TECSSemaphoreRef = TECSSemaphoreRef{\n"
                file.print "\tinner: unsafe{SemaphoreRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_#{@@ex_ctrl_ref_id}).unwrap())},\n"
                file.print "};\n\n"
                gen_semaphore_static_api_for_configuration cell
            when "mutex"
                file.print "pub static #{cell.get_global_name.to_s.upcase}_EX_CTRL_REF: TECSMutexRef = TECSMutexRef{\n"
                file.print "\tinner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_#{@@ex_ctrl_ref_id}).unwrap())},\n"
                file.print "};\n\n"
                gen_mutex_static_api_for_configuration cell
            end
        end
    end

    # ロックガードに Drop トレイトを実装する
    def gen_rust_impl_drop_for_lock_guard_structure file, celltype
        return if celltype.get_var_list.length == 0

        result = check_gen_dyn_for_ex_ctrl_ref celltype
        return if result == "dummy"

        file.print "impl"
        celltype.get_var_list.each{ |var|
            var_type_name = var.get_type.get_type_str
            if check_lifetime_annotation_for_type(var_type_name) then
                file.print "<'a>"
                break
            end
        }
        file.print " Drop for LockGuardFor#{get_rust_celltype_name(celltype)}"
        celltype.get_var_list.each{ |var|
            var_type_name = var.get_type.get_type_str
            if check_lifetime_annotation_for_type(var_type_name) then
                file.print "<'a>"
                break
            end
        }
        file.print " {\n"
        file.print "\tfn drop(&mut self){\n"
        file.print "\t\tself.ex_ctrl_ref.unlock();\n"
        file.print "\t}\n"
        file.print "}\n\n"
    end

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
                        # get_cell_ref 関数の呼び出しを生成
                        file.print "\t\tlet "

                        # get_cell_ref 関数の返り値を格納するタプルを生成
                        tuple_name_list = []
                        callport_list.each{ |callport|
                            tuple_name_list.push "#{snake_case(callport.get_name.to_s)}"
                        }
                        celltype.get_attribute_list.each{ |attr|
                            if attr.is_omit? then
                                next
                            end
                            tuple_name_list.push "#{attr.get_name.to_s}"
                        }
                        if celltype.get_var_list.length != 0 then
                            tuple_name_list.push "var"
                            tuple_name_list.push "_lg"
                        end

                        if tuple_name_list.length != 1 then
                            file.print "("
                        end

                        tuple_name_list.each_with_index do |tuple_name, index|
                            if index == tuple_name_list.length - 1 then
                                file.print "#{tuple_name}"
                                break
                            end
                            file.print "#{tuple_name}, "
                        end

                        if tuple_name_list.length != 1 then
                            file.print ")"
                        end

                        file.print " = self.cell.get_cell_ref();\n"
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
    def change_cargo_toml path
        # cargo_toml_path = "#{path}/Cargo.toml"

        # # TODO: asp3 か fmp3 かは、何かしらで判断する必要がある
        # itron_rs_depenence = "itron = { version = \"= 0.1.9\", features = [\"asp3\", \"nightly\", \"unstable\"] }"

        # File.open(cargo_toml_path, "a") do |file|
        #     file.puts itron_rs_depenence
        #     file.puts ""
        # end

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
            file.puts "# target = \"thumbv7em-none-eabihf\"     # Cortex-M4F and Cortex-M7F (with FPU) (e.g., Spike-rt)"
            file.puts "# target = \"armv7a-none-eabi\"          # Bare Armv7-A (e.g., Zynq-7000 (Xilinx))"
        end
    end

    def extract_target_triple path
        config_toml_path = "#{path}/.cargo/config.toml"
        target_line = nil

        File.foreach(config_toml_path) do |line|
        # コメントされていない行かつ、"target =" を含む行を探す
        # TODO: Rustコンパイラの生成物で上手く代用できそう
            if line.strip.start_with?("target =")
                target_line = line.strip
                break
            end
        end
        
        # ターゲットトリプルを抽出
        if target_line
            match = target_line.match(/target = "(.*?)"/)
            return match ? match[1] : nil
        else
            return nil
        end
    end

    # TODO: 現在は、ライブラリとしてコンパイルすることを前提としている
    def check_call_chg_pri cargo_path, target_triple

        # TODO: ライブラリ名は itron に固定しており、ビルドも release に固定しているため、柔軟にする必要がある
        binary_bath = "#{cargo_path}/target/#{target_triple}/release/libitron.a"

        command = "arm-none-eabi-nm #{binary_bath} > #{$gen}/arm-none-eabi-nm.txt"

        if File.exist?(binary_bath) && check_option_main_or_lib == "lib" then
            if @@arm_none_eabi_nm_gen == false then
                system(command)
                @@arm_none_eabi_nm_gen = true
            end

            # chg_pri 関数が含まれているかを確認
            if File.readlines("#{$gen}/arm-none-eabi-nm.txt").any?{ |line| line.include?("chg_pri") } then
                return true
            else
                return false
            end
        else
            # *.a ファイルが存在しない場合、保守的に chg_pri が含まれていると判断する
            puts "Error: #{binary_bath} does not exist"
            return true
        end
    end

    # 他のRustプラグインで生成したい RUST_PLUGIN_TECSGEN_SRCS の要素
    def gen_extra_rust_plugin_tecsgen_srcs_for_makefile makefile
        makefile.print( "\t$(TECS_RUST_SRC_DIR)/kernel_cfg.rs \\\n" )
        makefile.print( "\t$(TECS_RUST_SRC_DIR)/tecs_ex_ctrl.rs \\\n" )
        makefile.print( "\t$(TECS_RUST_SRC_DIR)/tecs_print.rs \\\n" )
    end

    # tecs_mutex.rs を生成する
    def gen_tecs_mutex_rs
        contents = <<~'EOS'
use itron::mutex::{MutexRef, LockError, UnlockError};
use crate::print;
use crate::tecs_print::*;
use itron::abi::uint_t;
use crate::tecs_ex_ctrl::*;

pub struct TECSMutexRef<'a>{
	pub inner: MutexRef<'a>,
}

impl LockManager for TECSMutexRef<'_>{
    #[inline]
    fn lock(&self){
        match self.inner.lock(){
            Ok(_) => {},
            Err(e) => {
                match e {
                    BadContext => {
                        print!("BadContextError::BadContext", );
                        loop{}
                    },
                    NotSupported => {
                        loop{}
                    },
                    BadId => {
                        print!("BadContextError::BadId", );
                        loop{}
                    },
                    AccessDenied => {
                        print!("BadContextError::AccessDenied", );
                        loop{}
                    },
                    Released => {
                        print!("BadContextError::Released", );
                        loop{}
                    },
                    TerminateErrorRequest => {
                        print!("TerminateErrorReason::BadContext", );
                        loop{}
                    },
                    Deleted => {
                        print!("BadContextError::Deleted", );
                        loop{}
                    },
                    BadParam => {
                        print!("BadContextError::BadParam", );
                        loop{}
                    },
                    DeadLock => {
                        print!("BadContextError::DeadLock", );
                        loop{}
                    },
                }
            },
        }
    }
    #[inline]
    fn unlock(&self){
        match self.inner.unlock(){
            Ok(_) => {},
            Err(e) => {
                match e {
                    BadContext => {
                        print!("BadContextError::BadContext", );
                        loop{}
                    },
                    BadId => {
                        print!("BadContextError::BadId", );
                        loop{}
                    },
                    AccessDenied => {
                        print!("BadContextError::AccessDenied", );
                        loop{}
                    },
                    BadSequence => {
                        print!("BadContextError::BadSequence", );
                        loop{}
                    },
                }
            },
        }
    }
}
            EOS

        mutex_file = CFile.open( "#{$gen}/tecs_mutex.rs", "w" )
        mutex_file.print contents
        mutex_file.close
    end

    # tecs_semaphore.rs を生成する
    def gen_tecs_semaphore_rs
        contents = <<~'EOS'
use itron::semaphore::{SemaphoreRef, WaitError, SignalError};
use crate::print;
use crate::tecs_print::*;
use itron::abi::uint_t;
use crate::tecs_ex_ctrl::*;

pub struct TECSSemaphoreRef<'a>{
	pub inner: SemaphoreRef<'a>,
}

impl LockManager for TECSSemaphoreRef<'_>{
    #[inline]
    fn lock(&self){
        match self.inner.wait(){
            Ok(_) => {},
            Err(e) => {
                match e {
                    BadContext => {
                        print!("BadContextError::BadContext", );
                        loop{}
                    },
                    NotSupported => {
                        loop{}
                    },
                    BadId => {
                        print!("BadContextError::BadId", );
                        loop{}
                    },
                    AccessDenied => {
                        print!("BadContextError::AccessDenied", );
                        loop{}
                    },
                    Released => {
                        print!("BadContextError::Released", );
                        loop{}
                    },
                    TerminateErrorRequest => {
                        print!("TerminateErrorReason::BadContext", );
                        loop{}
                    },
                    Deleted => {
                        print!("BadContextError::Deleted", );
                        loop{}
                    },
                }
            },
        }
    }
    #[inline]
    fn unlock(&self){
        match self.inner.signal(){
            Ok(_) => {},
            Err(e) => {
                match e {
                    BadContext => {
                        print!("BadContextError::BadContext", );
                        loop{}
                    },
                    BadId => {
                        print!("BadContextError::BadId", );
                        loop{}
                    },
                    AccessDenied => {
                        print!("BadContextError::AccessDenied", );
                        loop{}
                    },
                    QueueOverflow => {
                        print!("BadContextError::QueueOverflow", );
                        loop{}
                    },
                }
            },
        }
    }
}
            EOS

        mutex_file = CFile.open( "#{$gen}/tecs_semaphore.rs", "w" )
        mutex_file.print contents
        mutex_file.close
    end

    # tecs_mutex.rs と tecs_semaphore.rs の両方を含んだコードを生成する
    def gen_tecs_ex_ctrl_rs
        contents = <<~'EOS'
use itron::mutex::{MutexRef, LockError, UnlockError};
use itron::semaphore::{SemaphoreRef, WaitError, SignalError};
use crate::print;
use crate::tecs_print::*;
use itron::abi::uint_t;

pub trait LockManager {
    fn lock(&self);
    fn unlock(&self);
}

pub type TECSDummyLockGuard = u32;

pub struct TECSDummyExCtrlRef{}

pub struct TECSMutexRef<'a>{
	pub inner: MutexRef<'a>,
}

pub struct TECSSemaphoreRef<'a>{
	pub inner: SemaphoreRef<'a>,
}

#[link_section = ".rodata"]
pub static DUMMY_LOCK_GUARD: TECSDummyLockGuard = 0;

#[link_section = ".rodata"]
pub static DUMMY_EX_CTRL_REF: TECSDummyExCtrlRef = TECSDummyExCtrlRef{};

impl LockManager for TECSDummyExCtrlRef{
    #[inline]
    fn lock(&self){}
    #[inline]
    fn unlock(&self){}
}

impl LockManager for TECSMutexRef<'_>{
    #[inline]
    fn lock(&self){
        match self.inner.lock(){
            Ok(_) => {},
            Err(e) => {
                match e {
                    BadContext => {
                        print!("BadContextError::BadContext", );
                        loop{}
                    },
                    NotSupported => {
                        loop{}
                    },
                    BadId => {
                        print!("BadContextError::BadId", );
                        loop{}
                    },
                    AccessDenied => {
                        print!("BadContextError::AccessDenied", );
                        loop{}
                    },
                    Released => {
                        print!("BadContextError::Released", );
                        loop{}
                    },
                    TerminateErrorRequest => {
                        print!("TerminateErrorReason::BadContext", );
                        loop{}
                    },
                    Deleted => {
                        print!("BadContextError::Deleted", );
                        loop{}
                    },
                    BadParam => {
                        print!("BadContextError::BadParam", );
                        loop{}
                    },
                    DeadLock => {
                        print!("BadContextError::DeadLock", );
                        loop{}
                    },
                }
            },
        }
    }
    #[inline]
    fn unlock(&self){
        match self.inner.unlock(){
            Ok(_) => {},
            Err(e) => {
                match e {
                    BadContext => {
                        print!("BadContextError::BadContext", );
                        loop{}
                    },
                    BadId => {
                        print!("BadContextError::BadId", );
                        loop{}
                    },
                    AccessDenied => {
                        print!("BadContextError::AccessDenied", );
                        loop{}
                    },
                    BadSequence => {
                        print!("BadContextError::BadSequence", );
                        loop{}
                    },
                }
            },
        }
    }
}

impl LockManager for TECSSemaphoreRef<'_>{
    #[inline]
    fn lock(&self){
        match self.inner.wait(){
            Ok(_) => {},
            Err(e) => {
                match e {
                    BadContext => {
                        print!("BadContextError::BadContext", );
                        loop{}
                    },
                    NotSupported => {
                        loop{}
                    },
                    BadId => {
                        print!("BadContextError::BadId", );
                        loop{}
                    },
                    AccessDenied => {
                        print!("BadContextError::AccessDenied", );
                        loop{}
                    },
                    Released => {
                        print!("BadContextError::Released", );
                        loop{}
                    },
                    TerminateErrorRequest => {
                        print!("TerminateErrorReason::BadContext", );
                        loop{}
                    },
                    Deleted => {
                        print!("BadContextError::Deleted", );
                        loop{}
                    },
                }
            },
        }
    }
    #[inline]
    fn unlock(&self){
        match self.inner.signal(){
            Ok(_) => {},
            Err(e) => {
                match e {
                    BadContext => {
                        print!("BadContextError::BadContext", );
                        loop{}
                    },
                    BadId => {
                        print!("BadContextError::BadId", );
                        loop{}
                    },
                    AccessDenied => {
                        print!("BadContextError::AccessDenied", );
                        loop{}
                    },
                    QueueOverflow => {
                        print!("BadContextError::QueueOverflow", );
                        loop{}
                    },
                }
            },
        }
    }
}
            EOS

        # get_diff_between_gen_and_src "tecs_ex_ctrl.rs"
        ex_file = CFile.open( "#{$gen}/tecs_ex_ctrl.rs", "w" )
        ex_file.print contents
        ex_file.close

        if File.exist?("#{@@cargo_path}}/tecs_ex_ctrl.rs") == false then
            copy_gen_files_to_cargo "tecs_ex_ctrl.rs"
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
