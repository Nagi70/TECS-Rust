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
class ItronrsGenCelltypePlugin < RustGenCelltypePlugin
    CLASS_NAME_SUFFIX = ""
    @@b_signature_header_generated = false
    @@module_generated = false

    #celltype::     Celltype        セルタイプ（インスタンス）
    def initialize( celltype, option )
      super
      @celltype = celltype
      @plugin_arg_str = option.gsub( /\A"(.*)/, '\1' )    # 前後の "" を取り除く
      @plugin_arg_str.sub!( /(.*)"\z/, '\1' )
      @plugin_arg_str = CDLString.remove_dquote option
      @plugin_arg_list = {}
      @cell_list =[]
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
    def get_itronrs_kernel_obj_ref_str celltype_name
        case celltype_name
        when "tTask_rs"
            return "TaskRef"
        when "tSemaphore_rs"
            return "SemaphoreRef"
        when "tEventflag_rs"
            return "EventflagRef"
        when "tDataqueue_rs"
            return "DataqueueRef"
        when "tMutex_rs"
            return "MutexRef"
        else
            return "unknown"
        end
    end

    def gen_mod_in_main_lib_rs_for_celltype celltype
        plugin_option = @plugin_arg_str.strip
        if plugin_option == "main" || plugin_option == "lib" then
            tempfile = CFile.open( "#{$gen}/#{plugin_option}.rs", "a" )
            tempfile.print "#![no_std]\n"
            tempfile.print "#![feature(const_option)]\n"
            tempfile.print "mod kernel_cfg;\n"
            tempfile.print "mod tecs_mutex;\n"
            tempfile.print "mod tecs_print;\n"
            tempfile.close
        end
        super(celltype)
    end

    # @use_string_list に格納されている文字列を元に use 文を生成する
    def gen_use_header file
        obj_ref_str = get_itronrs_kernel_obj_ref_str @celltype.get_global_name.to_s
        if obj_ref_str != "unknown" then
            # file.print "use crate::kernel_obj_ref::*;  //特別な生成部\n"
            file.print "use itron::abi::*;\n"
            # TODO: task の部分の変換
            file.print "use itron::task::#{obj_ref_str};\n"
        end
        file.print "use core::cell::UnsafeCell;\n"
        file.print "use crate::tecs_mutex::*;\n"
        file.print "use core::num::NonZeroI32;\n"
        file.print "use crate::kernel_cfg::*;\n"
        super(file)
    end

    # セル構造体の変数フィールドの定義を生成
    def gen_rust_cell_structure_variable file, celltype
        if celltype.get_var_list.length != 0 then
            file.print "\tvariable: Sync#{get_rust_celltype_name(celltype)}Var"
            celltype.get_var_list.each{ |var|
                var_type_name = var.get_type.get_type_str
                if check_lifetime_annotation(var_type_name) then
                    file.print "<'a>"
                    break
                end
            }
            file.print ",\n"
        end
    end

    
    # セル構造体の mutex_ref フィールドの定義を生成
    def gen_rust_cell_structure_mutex_ref file, celltype
        return if celltype.get_var_list.length == 0

        result = check_gen_dyn_for_mutex_ref celltype
        if result == "dyn" then
            file.print "\tmutex_ref: &'a (dyn LockableForMutex + Sync + Send),\n"
        elsif result == "dummy" then
            # file.print "\tmutex_ref: &'a TECSDummyMutexRef,\n"
        else
            file.print "\tmutex_ref: &'a TECSMutexRef<'a>,\n"
        end
    end

    # Sync変数構造体の定義を生成
    def gen_rust_sync_variable_structure file, celltype
        if celltype.get_var_list.length != 0 then
            file.print "pub struct Sync#{get_rust_celltype_name(celltype)}Var"
            celltype.get_var_list.each{ |var|
                var_type_name = var.get_type.get_type_str
                if check_lifetime_annotation(var_type_name) then
                    file.print "<'a>"
                    break
                end
            }
            file.print "{\n"
            file.print "\tunsafe_var: UnsafeCell<#{get_rust_celltype_name(celltype)}Var"
            celltype.get_var_list.each{ |var|
                var_type_name = var.get_type.get_type_str
                if check_lifetime_annotation(var_type_name) then
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
            if check_lifetime_annotation(var_type_name) then
                file.print "<'a>"
                break
            end
        }
        file.print " Sync for Sync#{get_rust_celltype_name(celltype)}Var"
        celltype.get_var_list.each{ |var|
            var_type_name = var.get_type.get_type_str
            if check_lifetime_annotation(var_type_name) then
                file.print "<'a>"
                break
            end
        }
        file.print " {}\n\n"
    end

    # ミューテックスガード構造体の定義を生成
    def gen_rust_mutex_guard_structure file, celltype
        return if celltype.get_var_list.length == 0

        result = check_gen_dyn_for_mutex_ref celltype

        return if result == "dummy"

        file.print "pub struct LockGuardFor#{get_rust_celltype_name(celltype)}<'a>{\n"

        if result == "dyn" then
            file.print "\tmutex_ref: &'a (dyn LockableForMutex + Sync + Send),\n"
        # elsif result == "dummy" then
        #     file.print "\tmutex_ref: &'a TECSDummyMutexRef,\n"
        else
            file.print "\tmutex_ref: &'a TECSMutexRef<'a>,\n"
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
                if str == "TaskRef" then
                    # ライフタイムを付与
                    str = "TaskRef<'a>"
                    file.print "#{str},\n"
                    # 書き込んでいるファイルを一度閉じる
                    # file.close
                    # creat_itron_rs_use cell
                    # global_file_name = snake_case(cell.get_global_name.to_s)
                    # file = CFile.open( "#{$gen}/#{global_file_name}.rs", "a" )
                else
                    file.print "#{str},\n"
                end
            end
        }
    end
    
    # 呼び先のセルタイプが ITRON オブジェクトかどうかを判断する
    def check_callee_port_celltype_is_itron_object port
        itron_object_list = ["tTask_rs", "tSemaphore_rs", "tEventflag_rs", "tDataqueue_rs", "tMutex_rs"]
        if port.get_port_type == :CALL then
            callee_celltype_name = port.get_real_callee_cell.get_celltype.get_global_name.to_s
            if itron_object_list.include?(callee_celltype_name) then
                return true
            end
        end
        return false
    end

    def gen_use_for_trait_files file, celltype, port
        super(file, celltype, port)
        if port.get_port_type == :ENTRY then
            object_ref = get_itronrs_kernel_obj_ref_str celltype.get_global_name.to_s
            file.print "use itron::abi::*;\n"
            object_module = object_ref.gsub(/Ref/, "").downcase
            file.print "use itron::#{object_module}::#{object_ref};\n"
        end
    end

    def gen_rust_get_cell_ref file, celltype, callport_list, use_jenerics_alphabet
        # セルタイプに受け口がない場合は，生成しない
        # 受け口がないならば，get_cell_ref 関数が呼ばれることは現状無いため
        celltype.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then
                jenerics_flag = true
                file.print "impl"
                if check_only_entryport_celltype(celltype) then
                else
                    # check_only_entryport_celltype では，dyn な呼び口を判定していないため，ここで判定する
                    celltype.get_port_list.each{ |port|
                        if check_gen_dyn_for_port(port) == nil && use_jenerics_alphabet.length != 0 then
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
                    if check_lifetime_annotation(var_type_name) then
                        file.print "'a, "
                        break
                    end
                }
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
                        if check_gen_dyn_for_port(port) == nil && use_jenerics_alphabet.length != 0 then
                            file.print ">"
                        end
                        break
                    }
                end

                # impl する型を生成
                file.print " #{get_rust_celltype_name(celltype)}"
                if check_only_entryport_celltype(celltype) then
                else
                    file.print "<'"
                    # ライフタイムアノテーションの生成部
                    # TODO：ライフタイムについては，もう少し厳格にする必要がある
                    if celltype.get_var_list.length != 0 then
                        celltype.get_var_list.each{ |var|
                            var_type_name = var.get_type.get_type_str
                            if check_lifetime_annotation(var_type_name) then
                                file.print "a"
                                break
                            else
                                file.print "_"
                                break
                            end
                        }
                    else
                        file.print "_"
                    end
                    callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
                        if check_gen_dyn_for_port(callport) == nil then
                            file.print ", #{alphabet}"
                        end
                    end
                    file.print ">"
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
                    if check_lifetime_annotation(var_type_name) then
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
                    return_tuple_type_list.push("&#{alphabet}")
                    return_tuple_list.push("self.#{snake_case(callport.get_name.to_s)}")
                end

                # 属性をタプルの配列に追加
                celltype.get_attribute_list.each{ |attr|
                    if attr.is_omit? then
                        next
                    end
                    return_tuple_type_list.push("&#{c_type_to_rust_type(attr.get_type)}")
                    return_tuple_list.push("&self.#{attr.get_name.to_s}")
                }

                # 変数をタプルの配列に追加
                if celltype.get_var_list.length != 0 then
                    return_tuple_type_list.push("&mut #{get_rust_celltype_name(celltype)}Var")
                    # celltype.get_var_list.each{ |var|
                    #     var_type_name = var.get_type.get_type_str
                    #     if check_lifetime_annotation(var_type_name) then
                    #         return_tuple_type_list[-1].concat("<'a>")
                    #         break
                    #     end
                    # }
                    # return_tuple_type_list[-1].concat(">")
                    return_tuple_list.push("unsafe{&mut *self.variable.unsafe_var.get()}")
                end

                # ミューテックスガードを配列に追加
                # TODO: 変数が無い、もしくはダミーだけの時にはミューテックスガードを生成しなくてもいいかも。しかし、get_cell_ref の返り値の数はそろえる必要がある
                if celltype.get_var_list.length != 0 then
                    result = check_gen_dyn_for_mutex_ref celltype
                    if result == "dummy" then
                        return_tuple_type_list.push("&TECSDummyLockGuard")
                        return_tuple_list.push("&DUMMY_LOCK_GUARD")
                    else
                        return_tuple_type_list.push("LockGuardFor#{get_rust_celltype_name(celltype)}")
                        return_tuple_list.push("LockGuardFor#{get_rust_celltype_name(celltype)}{\n\t\t\t\tmutex_ref: self.mutex_ref,\n\t\t\t}")
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
                    result = check_gen_dyn_for_mutex_ref celltype
                    if result != "dummy" then
                        file.print "\t\tself.mutex_ref.lock();\n"
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

    # mutex_ref フィールドの初期化を生成
    def gen_rust_cell_structure_mutex_ref_initialize file, celltype, cell
        return if celltype.get_var_list.length == 0

        result = check_gen_dyn_for_mutex_ref celltype
        return if result == "dummy"

        multiple = check_multiple_accessed_for_cell cell
        if multiple then
            file.print "\tmutex_ref: &#{cell.get_global_name.to_s.upcase}_MUTEX_REF,\n"
        else
            file.print "\tmutex_ref: &DUMMY_MUTEX_REF,\n"
        end
    end

    # itron のコンフィグレーションファイルにミューテックス静的APIを生成する
    def gen_mutex_static_api_for_configuration
        file = AppFile.open( "#{$gen}/tecsgen.cfg" )
        file.print "CRE_MTX( TECS_RUST_MUTEX_#{@@mutex_ref_id}, { TA_INHERIT });\n"
        file.close
        @@mutex_ref_id += 1
    end

    # Sync変数構造体の初期化を生成
    def gen_rust_variable_structure_initialize file, cell
        if @celltype.get_var_list.length != 0 then
            file.print "pub static #{cell.get_global_name.to_s.upcase}VAR: Sync#{get_rust_celltype_name(cell.get_celltype)}Var = Sync#{get_rust_celltype_name(cell.get_celltype)}Var {\n"
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

    # mutex_ref の初期化を生成
    def gen_rust_mutex_ref_initialize file, cell
        return if @celltype.get_var_list.length == 0
        multiple = check_multiple_accessed_for_cell cell
        if multiple then
            file.print "#[link_section = \".rodata\"]\n"
            file.print "pub static #{cell.get_global_name.to_s.upcase}_MUTEX_REF: TECSMutexRef = TECSMutexRef{\n"
            file.print "\tinner: unsafe{MutexRef::from_raw_nonnull(NonZero::new(TECS_RUST_MUTEX_#{@@mutex_ref_id}).unwrap())},\n"
            file.print "};\n\n"
            gen_mutex_static_api_for_configuration
        end
    end

    # ミューテックスガードに Drop トレイトを実装する
    def gen_rust_impl_drop_for_mutex_guard_structure file, celltype
        return if celltype.get_var_list.length == 0

        result = check_gen_dyn_for_mutex_ref celltype
        return if result == "dummy"

        file.print "impl"
        celltype.get_var_list.each{ |var|
            var_type_name = var.get_type.get_type_str
            if check_lifetime_annotation(var_type_name) then
                file.print "<'a>"
                break
            end
        }
        file.print " Drop for LockGuardFor#{get_rust_celltype_name(celltype)}"
        celltype.get_var_list.each{ |var|
            var_type_name = var.get_type.get_type_str
            if check_lifetime_annotation(var_type_name) then
                file.print "<'a>"
                break
            end
        }
        file.print " {\n"
        file.print "\tfn drop(&mut self){\n"
        file.print "\t\tself.mutex_ref.unlock();\n"
        file.print "\t}\n"
        file.print "}\n\n"
    end

    # セルタイプに受け口がある場合，受け口関数を生成する
    def gen_rust_entryport_function file, celltype, callport_list
        # セルタイプに受け口がある場合，impl を生成する
        celltype.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then
                sig = port.get_signature

                file.print "impl #{camel_case(snake_case(port.get_signature.get_global_name.to_s))} for #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(celltype)}<'_"
                file.print ">"
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

    # tecs_mutex.rs を生成する
    def gen_tecs_mutex_rs
        contents = <<~'EOS'
use itron::mutex::{MutexRef, LockError, UnlockError};
use crate::print;
use crate::print::*;

pub trait LockableForMutex {
    fn lock(&self);
    fn unlock(&self);
}

pub type TECSDummyLockGuard = u32;

pub struct TECSMutexRef<'a>{
	pub inner: MutexRef<'a>,
}

pub struct TECSDummyMutexRef{}

#[link_section = ".rodata"]
pub static DUMMY_MUTEX_GUARD: TECSDummyLockGuard = 0;

#[link_section = ".rodata"]
pub static DUMMY_MUTEX_REF: TECSDummyMutexRef = TECSDummyMutexRef{};

impl LockableForMutex for TECSMutexRef<'_>{
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

impl LockableForMutex for TECSDummyMutexRef{
    #[inline]
    fn lock(&self){}
    #[inline]
    fn unlock(&self){}
}
            EOS

        mutex_file = CFile.open( "#{$gen}/tecs_mutex.rs", "w" )
        mutex_file.print contents
        mutex_file.close
    end

    # syslog の Rust ラップである print.rs を生成する
    def gen_tecs_print_rs
        contents = <<~'EOS'
use itron::abi::*;

extern "C"{
    pub fn syslog_wri_log(prio: uint_t, p_syslog: *const Syslog) -> ER;
}

#[repr(C)]
pub struct Syslog {
    pub logtype: uint_t,
    pub logtim: HRTCNT,
    pub loginfo: [uint_t; TMAX_LONINFO],
}

pub type HRTCNT = u32;

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
            let mut ary : [uint_t; 6] = [0; 6];

            ary[0] = concat!($fmt, '\0').as_bytes().as_ptr() as uint_t;

            let mut _index = 1;
            $(
                {
                    ary[_index] = $arg as uint_t;
                    _index = _index + 1;
                }
            )*
            ary
        } ; 

        let mut _syslog = Syslog {
            logtype : LOG_TYPE_COMMENT,
            logtim : 0,
            loginfo : ini_ary
        };

        unsafe{
            let _ = syslog_wri_log(LOG_NOTICE, &_syslog);
        }
    };
}
            EOS

        print_file = CFile.open( "#{$gen}/tecs_print.rs", "w" )
        print_file.print contents
        print_file.close
    end
        
    #=== tCelltype_factory.h に挿入するコードを生成する
    # file 以外の他のファイルにファクトリコードを生成してもよい
    # セルタイププラグインが指定されたセルタイプのみ呼び出される
    def gen_factory file

        # @celltype.get_cell_list.each{ |cell|
        #     gen_mod_in_lib_rs_for_cell cell
        # }

        super(file)

        gen_tecs_mutex_rs

        gen_tecs_print_rs

        # @celltype.get_cell_list.each{ |cell|
        #     if cell.is_generate? then
        #         global_file_name = cell.get_global_name
        #         global_file_name = global_file_name.to_s
        #         global_file_name = snake_case(global_file_name)
        #     end
        #     # if File.exist?("#{$gen}/#{global_file_name}.rs") then
        #     #     return
        #     # else
        #         file4 = CFile.open( "#{$gen}/#{global_file_name}.rs", "w" )
        #     # end

        #     file4.print "#![no_std]\n"
        #     file4.print "#![feature(const_option)]\n"
        #     file4.print "\n"
        #     file4.print "use core::num::NonZeroI32;\n"
        #     file4.print "use itron::*;\n"
        #     @celltype.get_port_list.each{ |port|
        #         if port.get_port_type == :CALL then
        #             call_port_name = snake_case(port.get_name.to_s)
        #             callee_cell_name = snake_case(port.get_real_callee_cell.get_global_name.to_s)
        #             callee_port_structure_name = port.get_real_callee_port.get_name.to_s.upcase + "FOR" + port.get_real_callee_cell.get_global_name.to_s.upcase
        #             file4.print "use crate::#{callee_cell_name}::#{callee_port_structure_name} as #{call_port_name};\n"
        #         end
        #     }

        #     file4.print "\n"

        #     task_id = (cell.get_attr_initializer :id).to_s
        #     cell_id = cell.get_id.to_s
        #     file4.print "pub const #{task_id.upcase}: NonNullID = NonZeroI32::new(#{cell_id}).unwrap();\n"
        #     file4.print "pub const #{cell.get_global_name.to_s.upcase}: TaskRef = unsafe { TaskRef::from_raw_nonnull(#{task_id.upcase}) };\n"
        #     # file4.print "pub const #{task_id.upcase}: TaskRef = unsafe { TaskRef::from_raw_nonnull( NonZeroI32::new( #{cell_id} ).unwrap() ) };\n"
        #     file4.print "\n"
        #     file4.print "#[no_mangle]\n"
        #     file4.print "pub extern \"C\" fn tTask_start(_: usize) {\n"
        #     file4.print "/*tTask型の呼び口につながっているセルの関数を呼び出す*/\n"
        #     file4.print "\n"
        #     file4.print "\tc_task_body.main();\n"
        #     file4.print "\n"
        #     file4.print "}\n"


        # } # celltype.get_cell_list.each

    end

end
