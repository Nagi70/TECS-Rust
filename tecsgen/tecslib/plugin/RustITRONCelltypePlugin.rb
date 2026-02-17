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

class Cell
    include RustGenHelper

    def gen_rust_cell_structure_header_initialize_specifier file
        file.print "#[unsafe(link_section = \".rodata\")]\n"

        # 自分自身のセルタイプに適用されている RustGen 系のプラグインを探す
        # plugin = self.get_celltype.get_plugins.find { |p| p.kind_of?(RustITRONCelltypePlugin) }
        # plugin_option = plugin ? plugin.plugin_arg_str.split(",").map(&:strip) : []

        # セルタイプに async 呼び口がある場合は、pub を付与する
        # lib.rsから関数を呼び出すため
        if self.get_celltype.task || self.get_celltype.init_routine || self.get_celltype.int_service_routine then
            file.print "pub "
        end
    end

    # セルの排他制御をセマフォにするかどうかを判断する
    def check_gen_which_ex_ctrl
        # JSONファイルがパースされていない場合は，セマフォにしない
        if RustITRONCelltypePlugin.json_parse_result.length == 0 then
            puts "JSONファイルがパースされていません"
            return "mutex"
        end

        celltype = self.get_celltype.get_global_name.to_s
        if RustITRONCelltypePlugin.json_parse_result[self.get_global_name.to_s]["Celltype"] == celltype then
            # 優先度が同じタスクからのみアクセスされる場合は，セマフォにする
            if RustITRONCelltypePlugin.json_parse_result[self.get_global_name.to_s]["ExclusiveControl"] == "true" && RustITRONCelltypePlugin.json_parse_result[self.get_global_name.to_s]["PriorityList"].length == 1 then
                # ターゲットトリプルを取得
                target_triple = extract_target_triple RustITRONCelltypePlugin.cargo_path

                # chg_pri がある場合は，ミューテックスにする
                if target_triple != nil && check_call_chg_pri(RustITRONCelltypePlugin.cargo_path, target_triple) == true then
                    return "mutex"
                end
                return "semaphore"

            elsif RustITRONCelltypePlugin.json_parse_result[self.get_global_name.to_s]["ExclusiveControl"] == "true" then
                return "mutex"
            end
        end

        return "none"
    end

    # ex_ctrl_ref フィールドの初期化を生成
    def gen_rust_cell_structure_ex_ctrl_ref_initialize file
        celltype = self.get_celltype
        return if celltype.get_var_list.length == 0

        result = celltype.check_gen_dyn_for_ex_ctrl_ref
        return if result == "dummy"

        case self.check_exclusive_control
        when true
            file.print "\tex_ctrl_ref: &#{self.get_global_name.to_s.upcase}_EX_CTRL_REF,\n"
        else
            file.print "\tex_ctrl_ref: &DUMMY_EX_CTRL_REF,\n"
        end
    end

    # セルのミューテックスオブジェクトの優先度上限値を取得する
    def get_ceiling_priority
        # JSONファイルがパースされていない場合は、優先度上限を 1 として返す
        if RustITRONCelltypePlugin.json_parse_result.length == 0 then
            return 1
        end

        # puts "@@json_parse_result: #{RustITRONCelltypePlugin.json_parse_result}"

        celltype = self.get_celltype.get_global_name.to_s
        if RustITRONCelltypePlugin.json_parse_result[self.get_global_name.to_s]["Celltype"] == celltype then
            if RustITRONCelltypePlugin.json_parse_result[self.get_global_name.to_s]["ExclusiveControl"] == "true" && RustITRONCelltypePlugin.json_parse_result[self.get_global_name.to_s]["PriorityList"].length != 0 then
                return RustITRONCelltypePlugin.json_parse_result[self.get_global_name.to_s]["PriorityList"].min
            end
        end
        puts "Error: JSON file does not include #{self.get_global_name.to_s}"
        return 1
    end

    # Sync変数構造体の初期化を生成
    def gen_rust_variable_structure_initialize file, plugin
        if self.get_celltype.get_var_list.length != 0 then
            file.print "static #{self.get_global_name.to_s.upcase}VAR: Sync#{get_rust_celltype_name(self.get_celltype)}Var = Sync#{get_rust_celltype_name(self.get_celltype)}Var {\n"
            file.print "\t"
            gen_comments_safe_reason file
            file.print "\tunsafe_var: UnsafeCell::new(#{get_rust_celltype_name(self.get_celltype)}Var {\n"
            # 変数構造体のフィールドの初期化を生成
            gen_rust_variable_structure_field_initialize file, plugin
            file.print "\t}),\n"
            file.print "};\n\n"
        end
    end

    def gen_comments_safe_reason file
        case self.check_exclusive_control
        when true
            case check_gen_which_ex_ctrl
            when "semaphore"
                file.print "/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the semaphore object.\n"
            when "mutex"
                file.print "/// This UnsafeCell is accessed by multiple tasks, but is safe because it is operated exclusively by the mutex object.\n"
            end
        else
            case self.check_multiple_accessed
            when true
                # root に近いコンポーネントで排他制御を行っている場合
                file.print "/// This UnsafeCell is accessed by multiple tasks, but is secure because it is accessed exclusively, with exclusive control applied to the component closest to root.\n"
            else
                file.print "/// This UnsafeCell is safe because it is only accessed by one task due to the call flow and component structure of TECS.\n"
            end
        end
    end

    # ex_ctrl_ref の初期化を生成
    def gen_rust_ex_ctrl_ref_initialize file
        return if self.get_celltype.get_var_list.length == 0
        multiple = self.check_exclusive_control
        if multiple then
            file.print "#[unsafe(link_section = \".rodata\")]\n"
            case check_gen_which_ex_ctrl
            when "semaphore"
                file.print "static #{self.get_global_name.to_s.upcase}_EX_CTRL_REF: TECSSemaphoreRef = TECSSemaphoreRef{\n"
                file.print "\tinner: unsafe{SemaphoreRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_#{RustITRONCelltypePlugin.ex_ctrl_ref_id}).unwrap())},\n"
                file.print "};\n\n"
                self.gen_semaphore_static_api_for_configuration
            when "mutex"
                file.print "static #{self.get_global_name.to_s.upcase}_EX_CTRL_REF: TECSMutexRef = TECSMutexRef{\n"
                file.print "\tinner: unsafe{MutexRef::from_raw_nonnull(NonZeroI32::new(TECS_RUST_EX_CTRL_#{RustITRONCelltypePlugin.ex_ctrl_ref_id}).unwrap())},\n"
                file.print "};\n\n"
                self.gen_mutex_static_api_for_configuration
            end
        end
    end

    # RustASP3CelltypePlugin や RustFMP3CelltypePlugin などで、それぞれのタスクの静的APIを生成する
    def gen_task_static_api_for_configuration

    end

    # RustASP3CelltypePlugin や RustFMP3CelltypePlugin などで、それぞれの CRE_ISR を生成する
    def gen_isr_static_api_for_configuration

    end

    # RustASP3CelltypePlugin や RustFMP3CelltypePlugin などで、それぞれの ATT_INI を生成する
    def gen_ini_static_api_for_configuration

    end

    # itron のコンフィグレーションファイルにミューテックス静的APIを生成する
    # RustASP3CelltypePlugin や RustFMP3CelltypePlugin などで、具体的な静的APIの生成を実装する
    def gen_mutex_static_api_for_configuration
        
    end

    # itron のコンフィグレーションファイルにセマフォ静的APIを生成する
    # RustASP3CelltypePlugin や RustFMP3CelltypePlugin などで、具体的な静的APIの生成を実装する
    def gen_semaphore_static_api_for_configuration

    end

    # ビルドのためのダミーオブジェクトIDを生成する
    def add_dummy_id_to_kernel_cfg_rs name, id

        file_path = "#{$gen}/kernel_cfg.rs"

        # 初回のみファイルを生成する
        if RustITRONCelltypePlugin.kernel_cfg_rs_gen == false then
            File.write(file_path, "")
            RustITRONCelltypePlugin.set_kernel_cfg_rs_gen
        end

        # 既に同じ定義が存在する場合は追記しない
        if File.exist?(file_path)
            existing = File.read(file_path)
            return if existing.include?("pub const #{name}:")
        end

        kernel_cfg_rs = File.open(file_path, "a")

        if id > 0 then
            kernel_cfg_rs.print "pub const #{name}: i32 = #{id};\t//Dummy id\n"
        else
            kernel_cfg_rs.print "pub const #{name}: i32 = 1;\t//Dummy id\n"
        end
        kernel_cfg_rs.close
    end
end

class Celltype

    include RustGenHelper

    attr_accessor :task
    attr_accessor :int_service_routine
    attr_accessor :init_routine

    # セル構造体の呼び口フィールドの specifier を生成
    def check_rust_cell_structure_callport_specifier callport
        # tTaskRs がタスクオブジェクトであることを前提としている
        # extern 関数で、各ルーチンの呼び口を呼び出す生成をするため、pub が必要になる
        # plugin = self.get_plugin
        # plugin_option = plugin ? plugin.plugin_arg_str.split(",").map(&:strip) : []

        if self.task && snake_case(callport.get_name.to_s) == "c_task_body" then
            return "pub "
        elsif self.int_service_routine && snake_case(callport.get_name.to_s) == "ci_isr_body" then
            return "pub "
        elsif self.init_routine && snake_case(callport.get_name.to_s) == "c_initialize_routine_body" then
            return "pub "
        else
            return ""
        end

    end

    # セル構造体の変数フィールドの定義を生成
    def gen_rust_cell_structure_variable file
        if self.get_var_list.length != 0 then
            file.print "\tvariable: &'static Sync#{get_rust_celltype_name(self)}Var,\n"
        end
    end

    # セル構造体の ex_ctrl_ref フィールドの定義を生成
    def gen_rust_cell_structure_ex_ctrl_ref file
        return if self.get_var_list.length == 0

        case check_gen_dyn_for_ex_ctrl_ref
        when "dyn"
            file.print "\tex_ctrl_ref: &'static (dyn LockManager + Sync + Send),\n"
        when "dummy"
            # file.print "\tex_ctrl_ref: &'static TECSDummyMutexRef,\n"
        else
            case check_gen_dyn_or_mutex_or_semaphore
            when "mutex"
                file.print "\tex_ctrl_ref: &'static TECSMutexRef,\n"
            when "semaphore"
                file.print "\tex_ctrl_ref: &'static TECSSemaphoreRef,\n"
            when "dyn"
                # TODO: ミューテックスとセマフォの呼び分け自体にも動的ディスパッチを使うのは議論の余地あり
                file.print "\tex_ctrl_ref: &'static (dyn LockManager + Sync + Send),\n"
            end
        end
    end

    # Sync変数構造体の定義を生成
    def gen_rust_sync_variable_structure file
        if self.get_var_list.length != 0 then
            file.print "pub struct Sync#{get_rust_celltype_name(self)}Var {\n"
            file.print "\tunsafe_var: UnsafeCell<#{get_rust_celltype_name(self)}Var>,\n"
            file.print "}\n\n"
        end
    end

    # Syncトレイトの実装を生成
    def gen_rust_impl_sync_trait_for_sync_variable_structure file
        return if self.get_var_list.length == 0

        file.print "unsafe impl Sync for Sync#{get_rust_celltype_name(self)}Var {}\n\n"
    end

    # ロックガード構造体のヘッダーを生成
    def gen_rust_lock_guard_structure_header file, callport_list, use_jenerics_alphabet
        file.print "pub struct LockGuardFor#{get_rust_celltype_name(self)}"

        params = []
        # シングルトン最適化が行われ、ロックガードに属性以外の要素が存在しない場合、ライフタイムは不要
        if is_lock_guard_lifetime_required?(callport_list, use_jenerics_alphabet) then
            params << "'a"
        end

        # 属性があれば CONFIG を出す
        if self.get_attribute_list.any? { |attr| !attr.is_omit? } then
            params << "CONFIG: #{get_rust_celltype_name(self)}Config"
        end
        
        if params.length > 0 then
            file.print "<"
            file.print params.join(", ")
            file.print ">"
        end
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
    def gen_rust_lock_guard_structure_attribute file
        self.get_attribute_list.each{ |attr|
            next if attr.is_omit?
            
            file.print "\tpub #{attr.get_name.to_s}: "
            if is_attribute_optimization?(self) then
                celltype_name_camel = get_rust_celltype_name(self)
                attr_name_camel = camel_case(attr.get_name.to_s)
                file.print "#{celltype_name_camel}#{attr_name_camel}<CONFIG>,\n"
            else
                # itron-rsオブジェクトに対する，特別な生成
                str = c_type_to_rust_type(attr.get_type)
                case str
                when "TaskRef"
                    str = "TaskRef<'static>"
                when "SemaphoreRef"
                    str = "SemaphoreRef<'static>"
                when "EventflagRef"
                    str = "EventflagRef<'static>"
                when "DataqueueRef"
                    str = "DataqueueRef<'static>"
                when "MutexRef"
                    str = "MutexRef<'static>"
                end
                file.print "&'a #{str},\n"
            end
        }

        # CONFIG が存在し、ZST 最適化でない場合は PhantomData が必要
        has_attr = self.get_attribute_list.any? { |attr| !attr.is_omit? }
        if has_attr && !is_attribute_optimization?(self) then
            file.print "\t_phantom: core::marker::PhantomData<CONFIG>,\n"
        end
    end

    # ロックガード構造体の変数への参照の定義を生成
    def gen_rust_lock_guard_structure_variable file
        if self.get_var_list.length != 0 then
            file.print "\tpub var: &'a mut #{get_rust_celltype_name(self)}Var,\n"
        end
    end

    # ロックガード構造体の定義を生成
    def gen_rust_lock_guard_structure file, callport_list, use_jenerics_alphabet

        if check_only_entryport_celltype then
            return
        end

        gen_rust_lock_guard_structure_header file, callport_list, use_jenerics_alphabet

        gen_rust_cell_structure_jenerics file, callport_list, use_jenerics_alphabet

        file.print "{\n"

        gen_rust_lock_guard_structure_callport file, callport_list, use_jenerics_alphabet

        gen_rust_lock_guard_structure_attribute file

        gen_rust_lock_guard_structure_variable file

        gen_rust_cell_structure_ex_ctrl_ref file

        file.print "}\n\n"
    end

    # セル構造体の属性フィールドの定義を生成
    def gen_attribute_field file, attr_name, attr_type_str
        case attr_type_str
        when "TaskRef"
            attr_type_str = "TaskRef<'static>"
        when "SemaphoreRef"
            attr_type_str = "SemaphoreRef<'static>"
        when "EventflagRef"
            attr_type_str = "EventflagRef<'static>"
        when "DataqueueRef"
            attr_type_str = "DataqueueRef<'static>"
        when "MutexRef"
            attr_type_str = "MutexRef<'static>"
        end
        file.print "\t#{attr_name}: #{attr_type_str},\n"
    end

    # get_cell_ref 関数のヘッダや引数はOSに依存するため、各OSのプラグインでオーバーライドする
    def gen_rust_get_cell_ref_header file, callport_list, use_jenerics_alphabet
        # インライン化
        file.print "\t#[inline]\n"

        # get_cell_ref 関数の定義を生成
        # TODO: get_cell_ref にライフタイムアノテーションが必要かも？
        file.print "\tpub fn get_cell_ref(&'static self) -> "

        file.print "LockGuardFor#{get_rust_celltype_name(self)}"

        # 属性の有無を確認
        has_attr = self.get_attribute_list.any? { |attr| !attr.is_omit? }

        # 以前は is_attribute_optimization? (フル定数化) の場合のみ CONFIG を出していたが、
        # size_first (非 ZST) の場合でも LockGuard は CONFIG を要求するため、
        # has_attr があれば常に CONFIG を出力するように変更する。
        if has_attr then
            lock_guard_first = true
            if self.get_var_list.length != 0 then
                file.print "<'_"
                lock_guard_first = false
            end
            # CONFIG ジェネリクス
            if lock_guard_first then
                if is_zst_optimization?(self) then
                    file.print "<CONFIG"
                else
                    file.print "<ConfigDefault#{get_rust_celltype_name(self)}"
                end
                lock_guard_first = false
            else
                if is_zst_optimization?(self) then
                    file.print ", CONFIG"
                else
                    file.print ", ConfigDefault#{get_rust_celltype_name(self)}"
                end
            end

            file.print ">"
        elsif check_only_entryport_celltype then
        else
            lock_guard_first = true
            if self.get_var_list.length != 0 then
                file.print "<'_"
                lock_guard_first = false
            end
            file.print ">" if lock_guard_first == false
        end

        file.print " {\n"
    end

    # 引数のセルタイプの ex_ctrl_ref に動的ディスパッチが必要かどうかを判断し、いる場合は dyn を、いらない場合は、ダミーかどうかを返す
    def check_gen_dyn_for_ex_ctrl_ref
        dyn_check_results = self.get_cell_list.map { |cell| cell.check_exclusive_control }
        
        if dyn_check_results.all?(true) then
            return "no_dummy"
        elsif dyn_check_results.all?(false) then
            return "dummy"
        else
            return "dyn"
        end
    end

    # ロックガードの変数フィールドの生成はOSに依存するので、各プラグインでオーバーライドする
    def gen_rust_lock_guard_initialize_variable file
        if self.get_var_list.length != 0 then
            file.print "\t\t\tvar: unsafe{&mut *self.variable.unsafe_var.get()},\n"
        end
        if self.get_var_list.length != 0 then
            result = check_gen_dyn_for_ex_ctrl_ref
            if result == "dummy" then
            else
                file.print "\t\t\tex_ctrl_ref: self.ex_ctrl_ref,\n"
            end
        end
    end

    # ロックガードの初期化前の処理はOSに依存するので、各プラグインでオーバーライドする
    def gen_rust_process_before_lock_guard_initialize file
        if self.get_var_list.length != 0 then
            result = check_gen_dyn_for_ex_ctrl_ref
            if result != "dummy" then
                file.print "\t\tself.ex_ctrl_ref.lock();\n"
            end
        end
    end

    # ミューテックスを適用するセルとセマフォを適用するセルが混在するセルタイプかどうかを判断する
    # TOPPERSでは、ミューテックスとセマフォどちらかを適用する
    def check_gen_dyn_or_mutex_or_semaphore
        check_semaphore = []

        self.get_cell_list.each{ |cell|
            check_semaphore.push(cell.check_gen_which_ex_ctrl).uniq!
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

    # ロックガードに Drop トレイトを実装する
    def gen_rust_impl_drop_for_lock_guard_structure file, callport_list, use_jenerics_alphabet
        return if self.get_var_list.length == 0

        result = self.check_gen_dyn_for_ex_ctrl_ref
        return if result == "dummy"

        file.print "impl" 

        if self.get_attribute_list.any? { |attr| !attr.is_omit? } then
            file.print "<CONFIG: #{get_rust_celltype_name(self)}Config>"
        end
        
        file.print " Drop for LockGuardFor#{get_rust_celltype_name(self)}"

        params = []
        # シングルトン最適化が行われ、ロックガードに属性以外の要素が存在しない場合、ライフタイムは不要
        if is_lock_guard_lifetime_required?(callport_list, use_jenerics_alphabet) then
            params << "'_"
        end

        # 属性があれば CONFIG を出す
        if self.get_attribute_list.any? { |attr| !attr.is_omit? } then
            params << "CONFIG"
        end
        
        if params.length > 0 then
            file.print "<"
            file.print params.join(", ")
            file.print ">"
        end

        file.print " {\n"
        file.print "\tfn drop(&mut self){\n"
        file.print "\t\tself.ex_ctrl_ref.unlock();\n"
        file.print "\t}\n"
        file.print "}\n\n"
    end
end

#== celltype プラグインの共通の親クラス
class RustITRONCelltypePlugin < RustGenCelltypePlugin
    CLASS_NAME_SUFFIX = ""
    @@b_signature_header_generated = false
    @@module_generated = false
    @@arm_none_eabi_nm_gen = false
    @@kernel_cfg_rs_gen = false
    @@rust_task_func_list = []
    @@rust_hadler_func_list = []
    @@rust_tecs_header_include = false
    @@task_func_list = []
    @@isr_func_list = []
    @@ini_func_list = []
    @@task_celltype_list = []
    @@task_signature_list = []
    @@isr_celltype_list = []
    @@isr_signature_list = []
    @@ini_celltype_list = []
    @@ini_signature_list = []

    # クラス変数へのアクセサメソッド
    def self.json_parse_result
        @@json_parse_result
    end

    def self.cargo_path
        @@cargo_path
    end

    def self.ex_ctrl_ref_id
        @@ex_ctrl_ref_id
    end

    def self.increment_ex_ctrl_ref_id
        @@ex_ctrl_ref_id += 1
    end

    def self.rust_task_func_list
        @@rust_task_func_list
    end

    def self.rust_tecs_header_include
        @@rust_tecs_header_include
    end

    def self.set_rust_tecs_header_include
        @@rust_tecs_header_include = true
    end

    def self.kernel_cfg_rs_gen
        @@kernel_cfg_rs_gen
    end

    def self.set_kernel_cfg_rs_gen
        @@kernel_cfg_rs_gen = true
    end

    attr_reader :plugin_arg_str

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
        elsif plugin_option.include?("INT_SERVICE_ROUTINE") then
            return "ID"
        else
            return "unknown"
        end
    end

    def gen_mod_in_main_lib_rs file, celltype
        file.print "mod kernel_cfg;\n"
        file.print "mod tecs_ex_ctrl;\n"
        file.print "mod tecs_print;\n"
        super(file, celltype)
    end

    def gen_compile_option_in_main_lib_rs file, celltype
        file.print "#![no_std]\n"
        file.print "#![feature(const_option)]\n"
    end

    def gen_entryport_function_in_main_lib_rs file, celltype
        plugin_option = @plugin_arg_str.split(",").map(&:strip)

        # 一番最初のタスク関数生成の時だけ、以下のパニックハンドラと、二つのuse文を追加する
        gen_panic_handler_in_main_lib_rs file

        # オプションに応じて、クラス変数に追加と、静的APIを生成する
        if plugin_option.include?("TASK") then
            gen_task_func_definition file, celltype
        end
        if plugin_option.include?("INT_REQUEST") then
            # TODO: CFG_INT (ASP3の場合はファクトリ生成かもしれない)
        end
        if plugin_option.include?("INT_SERVICE_ROUTINE") then
            gen_isr_func_definition file, celltype
        end
        if plugin_option.include?("INT_HANDLER") then
            # TODO: DEF_INH
        end
        if plugin_option.include?("CPU_EXCEPTION_HANDLER") then
            # TODO: DEF_EXC
        end
        if plugin_option.include?("INIT_ROUTINE") then
            gen_ini_func_definition file, celltype
        end
        if plugin_option.include?("TERM_ROUTINE") then
            # TODO: ATT_TER
        end

        # クラス変数に追加したものをファイルに出力する
        if @@task_celltype_list.length != 0 then
            file.print @@task_celltype_list.join("\n") + "\n"
            file.print @@task_signature_list.join("\n") + "\n"
            file.print @@task_func_list.join("\n") + "\n"
        end
        if @@isr_celltype_list.length != 0 then
            file.print @@isr_celltype_list.join("\n") + "\n"
            file.print @@isr_signature_list.join("\n") + "\n"
            file.print @@isr_func_list.join("\n") + "\n"
        end
        if @@ini_celltype_list.length != 0 then
            file.print @@ini_celltype_list.join("\n") + "\n"
            file.print @@ini_signature_list.join("\n") + "\n"
            file.print @@ini_func_list.join("\n") + "\n"
        end

    end

    def gen_task_func_definition file, celltype

        @@task_celltype_list.push("use tecs_celltype::" + snake_case(celltype.get_global_name.to_s) + "::*;")
        @@task_signature_list.push("use tecs_signature::s_task_body::*;")

        # タスク関数のリストに追加する
        celltype.get_cell_list.each{ |cell|
            @@task_func_list.push(
                "\n#[unsafe(no_mangle)]\n" +
                "pub extern \"C\" fn tecs_rust_start_" + snake_case(cell.get_global_name.to_s) + "(_: usize) {\n" +
                "\t#{cell.get_global_name.to_s.upcase}.c_task_body.main();\n" +
                "}"
            )
            # 何度も呼び出されるが、重複して静的APIを生成しないように関数内で管理している
            cell.gen_task_static_api_for_configuration
        }

        # 重複を削除する
        @@task_celltype_list.uniq!
        @@task_signature_list.uniq!
        @@task_func_list.uniq!

    end

    # lib.rs や main.rs に対して、extern関数を生成する
    # TODO: リファクタリングの際に、タスクや他のハンドラの関数と一緒にしたい
    def gen_isr_func_definition file, celltype


        @@isr_celltype_list.push("use tecs_celltype::" + snake_case(celltype.get_global_name.to_s) + "::*;")
        @@isr_signature_list.push("use tecs_signature::si_handler_body::*;")

        celltype.get_cell_list.each{ |cell|
            @@isr_func_list.push(
                "\n#[unsafe(no_mangle)]\n" +
                "pub extern \"C\" fn tecs_rust_start_" + snake_case(cell.get_global_name.to_s) + "(_: usize) {\n" +
                "\t#{cell.get_global_name.to_s.upcase}.ci_isr_body.main();\n" +
                "}"
            )
            # 何度も呼び出されるが、重複して静的APIを生成しないように関数内で管理している
            cell.gen_isr_static_api_for_configuration
        }

        # 重複を削除する
        @@isr_celltype_list.uniq!
        @@isr_signature_list.uniq!
        @@isr_func_list.uniq!

    end

    def gen_ini_func_definition file_option, celltype

        @@ini_celltype_list.push("use tecs_celltype::" + snake_case(celltype.get_global_name.to_s) + "::*;")
        @@ini_signature_list.push("use tecs_signature::s_routine_body::*;")

        celltype.get_cell_list.each{ |cell|
            @@ini_func_list.push(
                "\n#[unsafe(no_mangle)]\n" +
                "pub extern \"C\" fn tecs_rust_start_" + snake_case(cell.get_global_name.to_s) + "(_: usize) {\n" +
                "\t#{cell.get_global_name.to_s.upcase}.c_initialize_routine_body.main();\n" +
                "}"
            )
            # 何度も呼び出されるが、重複して静的APIを生成しないように関数内で管理している
            cell.gen_ini_static_api_for_configuration
        }

        # 重複を削除する
        @@ini_celltype_list.uniq!
        @@ini_signature_list.uniq!
        @@ini_func_list.uniq!

    end

    def gen_panic_handler_in_main_lib_rs file

        file.print "\n#[panic_handler]\n"
        file.print "fn panic(_panic: &core::panic::PanicInfo<'_>) -> ! {\n"
        file.print "\tloop {}\n"
        file.print "}\n\n"
    end

    # タスクや変数に適用されるカーネルオブジェクト以外のオブジェクトIDを生成する
    # TODO: 現在はミューテックス、データキュー、セマフォのみ対応
    def gen_kernel_object_id_in_kernel_cfg_rs celltype

        obj = get_itronrs_kernel_obj_ref_str

        if obj == "MutexRef" || obj == "DataqueueRef" || obj == "SemaphoreRef" then
            celltype.get_cell_list.each{ |cell|
                id = cell.get_attr_initializer("id".to_sym)
                cell.add_dummy_id_to_kernel_cfg_rs id, 1
            }
        end
    end

    def gen_rust_tecs_h

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

    

    def gen_use_mutex file

        case @celltype.check_gen_dyn_or_mutex_or_semaphore
        when "mutex"
            file.print "use itron::mutex::MutexRef;\n"
        when "semaphore"
            file.print "use itron::semaphore::SemaphoreRef;\n"
        when "dyn" # TODO: ダミー+セマフォorミューテックスのケースでは、片方の生成だけでいい
            file.print "use itron::mutex::MutexRef;\n"
            file.print "use itron::semaphore::SemaphoreRef;\n"
        end

        file.print "use crate::tecs_ex_ctrl::*;\n" # TODO: 本当に排他制御が必要なときのみ生成するようにする
        file.print "use core::cell::UnsafeCell;\n"
        file.print "use core::num::NonZeroI32;\n"
        file.print "use crate::kernel_cfg::*;\n"
    end

    # TODO: 現在は、ライブラリとしてコンパイルすることを前提としている
    # バイナリに chg_pri 関数が含まれているかを確認する
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

    def gen_use_header file
        kernel_obj = get_itronrs_kernel_obj_ref_str
        if kernel_obj != "unknown" then
            if kernel_obj == "ID" then
                file.print "use itron::abi::#{kernel_obj};\n"
            else
                file.print "use itron::#{kernel_obj[0..-4].downcase}::#{kernel_obj};\n"
            end
            file.print "use core::num::NonZeroI32;\n"
            file.print "use crate::kernel_cfg::*;\n"
        end
        
        super(file)
    end

    # Cargo の新規プロジェクトを作成する
    def cargo_new_project path
        super(path)

        gen_config_toml path

    end

    # Cargo.toml の設定を変更する
    def change_cargo_toml path
        super(path)
        
        cargo_toml_path = "#{path}/Cargo.toml"

        # TODO: main と lib の指定が混ざっている場合、どちらを選択するかを決める必要がある
        if check_option_main_or_lib == "lib" then
            File.open(cargo_toml_path, "a") do |file|
                file.puts "[lib]"
                file.puts "name = \"itron\""
                file.puts "crate-type = [\"staticlib\"]"
            end
        end
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

pub struct TECSMutexRef{
	pub inner: MutexRef<'static>,
}

impl LockManager for TECSMutexRef{
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

pub struct TECSSemaphoreRef{
	pub inner: SemaphoreRef<'static>,
}

impl LockManager for TECSSemaphoreRef{
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

pub struct TECSMutexRef{
	pub inner: MutexRef<'static>,
}

pub struct TECSSemaphoreRef{
	pub inner: SemaphoreRef<'static>,
}

#[unsafe(link_section = ".rodata")]
pub static DUMMY_LOCK_GUARD: TECSDummyLockGuard = 0;

#[unsafe(link_section = ".rodata")]
pub static DUMMY_EX_CTRL_REF: TECSDummyExCtrlRef = TECSDummyExCtrlRef{};

impl LockManager for TECSDummyExCtrlRef{
    #[inline]
    fn lock(&self){}
    #[inline]
    fn unlock(&self){}
}

impl LockManager for TECSMutexRef{
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

impl LockManager for TECSSemaphoreRef{
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

        ex_file = CFile.open( "#{$gen}/tecs_ex_ctrl.rs", "w" )
        ex_file.print contents
        ex_file.close

        if File.exist?("#{@@cargo_path}}/tecs_ex_ctrl.rs") == false then
            copy_gen_files_to_cargo "tecs_ex_ctrl.rs", nil
        end
    end

    #=== tCelltype_factory.h に挿入するコードを生成する
    # file 以外の他のファイルにファクトリコードを生成してもよい
    # セルタイププラグインが指定されたセルタイプのみ呼び出される
    def gen_factory file

        plugin_option = @plugin_arg_str.split(",").map(&:strip)
        if plugin_option.include?("TASK") then
            @celltype.task = true
        end
        if plugin_option.include?("INT_SERVICE_ROUTINE") then
            @celltype.int_service_routine = true
        end
        if plugin_option.include?("INIT_ROUTINE") then
            @celltype.init_routine = true
        end

        super(file)

        # TODO: 必要なときにのみ生成するようにする
        print "#{@celltype.get_global_name.to_s}: gen_tecs_ex_ctrl_rs\n"
        gen_tecs_ex_ctrl_rs

        # TODO: 必要なときにのみ生成するようにする
        # gen_tecs_mutex_rs

        # TODO: 必要なときにのみ生成するようにする
        # gen_tecs_semaphore_rs
        print "#{@celltype.get_global_name.to_s}: gen_tecs_print_rs\n"
        gen_tecs_print_rs

        print "#{@celltype.get_global_name.to_s}: gen_rust_tecs_h\n"
        gen_rust_tecs_h

        # カーネルオブジェクトコンポーネントの ID を生成する
        print "#{@celltype.get_global_name.to_s}: gen_kernel_object_id_in_kernel_cfg_rs\n"
        gen_kernel_object_id_in_kernel_cfg_rs @celltype

        print "#{@celltype.get_global_name.to_s}: copy_gen_files_to_cargo\n"
        copy_gen_files_to_cargo "kernel_cfg.rs", nil
    end

end
