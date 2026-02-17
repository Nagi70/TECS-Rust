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


module RustGenHelper
    def get_rust_celltype_name celltype
        return camel_case(snake_case(celltype.get_global_name.to_s))
    end
    def get_rust_function_name func_head
        return snake_case(func_head.get_name.to_s)
    end

    # 文字列を snake_case に変換する
    def snake_case(input_string)
        # string = input_string.to_s
        input_string.gsub(/([a-z0-9])([A-Z])/, '\1_\2')      # 小文字→大文字の間
        .gsub(/([A-Z])([A-Z][a-z])/, '\1_\2')    # 大文字→大文字＋小文字の間
        .downcase
    end

    # 文字列を camelCase に変換する
    def camel_case(input_string)
        input_string.split('_').map(&:capitalize).join
    end

    # 正規表現のパターンを用いて，型にライフタイムが必要かチェックする関数
    # 正規表現のパターン以外には対応していない
    def check_lifetime_annotation_for_type str
        if str.include?("&") then
            return true
        else
            return false
        end
    end

    # get_bit_size の返り値を Rust の型に合わせて変換する
    # TODO: 厳密な変換にする必要がある
    def convert_bit_size bit_size
        if bit_size > 0 then
            return bit_size
        end
        case bit_size
        when -11 then return 8
        when -1  then return 8
        when -2  then return 16
        when -3  then return 32
        when -4  then return 64
        when -5  then return 128
        else
            return bit_size.abs
        end
    end

    def is_size_first?(celltype)
        return RustGenCelltypePlugin.size_first_celltypes[celltype.get_global_name] == true
    end

    def is_attribute_optimization?(celltype)
        # 「省略されない属性」があり、かつ（「size_first 指定がない」または「シングルトンである」）場合に true
        # シングルトンの場合はメモリ節約のため常に ZST 最適化を適用する
        has_attr = celltype.get_attribute_list.any? { |attr| !attr.is_omit? }
        return has_attr && (!is_size_first?(celltype) || is_singleton_optimization?(celltype))
    end

    # 属性の実体として ZST (定数) を使用すべきかどうか (is_attribute_optimization? の別名)
    def is_zst_optimization?(celltype)
        return is_attribute_optimization?(celltype)
    end

    # シングルトン最適化対象かどうかを返す
    def is_singleton_optimization?(celltype)
        celltype.get_cell_list.length == 1
    end

    # 宣言されている型を Rust の型に変換する
    # 現状として，int8_t, int16_t, int32_t, int64_t のみ対応
    # TODO:他の型への対応
    def c_type_to_rust_type c_type

        if c_type.kind_of?( IntType ) then
            # TODO: ここで符号付きかどうかを判断する
            if c_type.get_sign == :SIGNED then
                str = "i#{convert_bit_size(c_type.get_bit_size)}"
            elsif c_type.get_sign == :UNSIGNED then
                str = "u#{convert_bit_size(c_type.get_bit_size)}"
            else
                str = "i#{convert_bit_size(c_type.get_bit_size)}"
            end
        elsif c_type.kind_of?( BoolType ) then
            str = "bool"
        elsif c_type.kind_of?( FloatType ) then
            case c_type.get_bit_size
            when 32   then str = "f32"
            when 64   then str = "f64"
            when -32  then str = "f32"
            when -64  then str = "f64"
            when -128 then str = "f128"
            end
        elsif c_type.kind_of?( ArrayType ) then
            type = c_type_to_rust_type(c_type.get_type)
            subscript = c_type.get_subscript
            str = "[#{type}; #{subscript}]"
        elsif c_type.kind_of?( StructType ) then
            str = c_type.get_name.to_s
            # TODO: 構造体の定義がある場合は、その構造体の定義を生成する。
            # すべてのオリジナル構造体の定義を tecs_global.rs に生成する
            # @@struct_type_list.push(c_type)

            # Rust のコード生成で使用されているオリジナル構造体のリストに追加する
            # @@used_in_rust_custom_struct_list[c_type.get_name.to_s] = c_type
            RustGenCelltypePlugin.add_used_in_rust_custom_struct_list(c_type.get_name.to_s, c_type)

            # @gen_use_global = true
        elsif c_type.kind_of?( PtrType ) then
            if c_type.get_string != nil then
                # str = "#{c_type.has_sized_pointer?}"
                # str = "#{c_type.get_max}"
                # [out,string(len)]の場合は，ここでlenが返ってくる
                # [out,string(256)]の場合は，256が返ってくる
                # [in, string]の場合は，-1が返ってくる
                # str = "#{c_type.get_string}"
                # c_type.get_stringが数字かどうかを判断する
                if c_type.get_string.to_s.match?(/^\d+$/)
                    string = c_type.get_string.to_s.to_i
                    if string <= 0 then
                        string = 256
                    end
                else
                    string = 256
                end

                # @@gen_heapless_crate_dependency = true
                RustGenCelltypePlugin.set_gen_heapless_crate_dependency(true)

                str = "heapless::String<#{string}>"

                if c_type.get_size != nil then
                    size = c_type.get_size.to_s.to_i
                    str.prepend("heapless::Vec::<")
                    str.concat(", #{size}>")
                end
            elsif c_type.get_size != nil then
                # TODO: size_is指定子のときの処理
                type = c_type_to_rust_type(c_type.get_type)
                # str = "[#{type}; #{c_type.get_size}]"
                str = "[#{type}]"
            elsif c_type.get_count != nil then
                type = c_type_to_rust_type(c_type.get_type)
                str = "[#{type}; #{c_type.get_size}]"
            elsif c_type.get_max != nil then
                str = "check_max"
            else
                # ポインタの中の型に対して，もう一度 c_type_to_rust_type を呼び出す
                type = c_type_to_rust_type(c_type.get_type)
                str = type.gsub("*", "")
                if str == "void" then
                    str = "unknown"
                end
            end
        elsif c_type.kind_of?( RTypeType ) then
            str = c_type.get_type_str_inner
            # str の中にカスタム構造体が含まれているかどうかをチェックする

            root = Namespace.get_root
            structs = []  # Array<StructType>

            traverse = lambda do |ns|
                decls = ns.instance_variable_get(:@decl_list) || []
                decls.each do |d|
                    structs << d if d.kind_of?(StructType)
                end
                ns.get_namespace_list.each { |child| traverse.call(child) }
            end

            traverse.call(root)

            structs.each do |st|
                if str.include?(st.get_name.to_s) then
                    # Rust のコード生成で使用されているオリジナル構造体のリストに追加する
                    # @@used_in_rust_custom_struct_list[st.get_name.to_s] = st
                    RustGenCelltypePlugin.add_used_in_rust_custom_struct_list(st.get_name.to_s, st)
                end
            end
        else
            str = c_type.get_type_str
            if str == "void" then
                str = "unknown"
            end
            if c_type.is_const? || c_type.is_volatile? then
                original_type = c_type.get_original_type
                str = c_type_to_rust_type(original_type)
            end
        end
        return str
    end

    # 指定された TECS の型について、const/volatile 修飾子の有無と数値型の内訳を判定する
    # 入力: tecs_type => Type (Decl#get_type 等で取得した型オブジェクト)
    # 戻り値: Hash
    #   {
    #     const: true/false,
    #     volatile: true/false,
    #     numeric: {
    #       category: :int | :float | :enum,
    #       bit_size: Integer,   # IntType/FloatType の bit_size（IntType は抽象幅は負値: -3=int など）
    #       sign: :SIGNED | :UNSIGNED | nil  # IntType のみ
    #     } | nil
    #   }
    def detect_const_volatile_and_numeric(tecs_type)
        # 修飾子（const/volatile）は Type のフラグで取得できる
        is_const = false
        is_volatile = false
        begin
            is_const = tecs_type.is_const?
            is_volatile = tecs_type.is_volatile?
        rescue => _
            # 型が不正でもここでは握りつぶす
        end

        # typedef を辿って元の型へ。以降の判定は元型に対して行う
        base = nil
        begin
            base = tecs_type.get_original_type
        rescue => _
            base = tecs_type
        end

        numeric = nil
        if base.kind_of?(IntType)
            # IntType: bit_size は固定幅(>0)か抽象幅(負値)
            numeric = {
                category: :int,
                bit_size: base.get_bit_size,
                sign: base.get_sign # :SIGNED | :UNSIGNED | nil
            }
        elsif base.kind_of?(FloatType)
            numeric = {
                category: :float,
                bit_size: base.get_bit_size
            }
        elsif base.kind_of?(EnumType)
            numeric = {
                category: :enum,
                bit_size: -1
            }
        end

        { const: is_const, volatile: is_volatile, numeric: numeric }
    end

    # detect_const_volatile_and_numeric の numeric 結果から、人間可読な型名（C 風）を作る補助
    # 例: {category: :int, bit_size: 32, sign: :UNSIGNED} => "uint32_t"
    #     {category: :int, bit_size: -3, sign: :SIGNED}   => "int"
    #     {category: :float, bit_size: 64}                => "double64_t"
    def numeric_type_name(numeric)
        return nil unless numeric
        case numeric[:category]
        when :int
            bs = numeric[:bit_size]
            sign = numeric[:sign] == :UNSIGNED ? 'u' : ''
            if bs && bs > 0
                return "#{sign}int#{bs}_t"
            end
            case bs
            when -11 then return "#{sign}char"
            when -1  then return "#{sign}char_t"
            when -2  then return "#{sign}short"
            when -3  then return "#{sign}int"
            when -4  then return "#{sign}long"
            when -5  then return "#{sign}long long"
            else
                return "int"
            end
        when :float
            case numeric[:bit_size]
            when 32   then return "float32_t"
            when 64   then return "double64_t"
            when -32  then return "float"
            when -64  then return "double"
            when -128 then return "long double"
            else
                return "float"
            end
        when :enum
            return "enum"
        else
            nil
        end
    end
end


class Cell
    include RustGenHelper

    # 変数の初期値を得る
    def get_var_initializer var_name
        val = @join_list.get_item( var_name )
        if val == nil then
            v = @celltype.find( var_name )
            val = v ? v.get_initializer : nil
        else
            val = val.get_rhs
        end
        return val
    end

    # 属性の初期値を得る
    def get_attr_initializer attr_name
        val = @join_list.get_item( attr_name )
        if val == nil then
            v = @celltype.find( attr_name )
            val = v ? v.get_initializer : nil
        else
            val = val.get_rhs
        end
        return val
    end

    def get_rust_config_type
        celltype = self.get_celltype

        has_attr = celltype.get_attribute_list.any? { |attr| !attr.is_omit? }
        return nil if !has_attr

        # プラグインが見つからない場合は、デフォルトで ZST 最適化されていると仮定する（従来互換）
        # または、そのセルタイプが ZST 最適化されているかどうかを判定する
        if is_zst_optimization?(celltype) then
            return "Config#{camel_case(self.get_name.to_s)}"
        else
            return "ConfigDefault#{get_rust_celltype_name(celltype)}"
        end
    end

    # セルが複数のタスクからアクセスされているかどうかを判断する
    def check_exclusive_control
        # JSONファイルがパースされていない場合は、排他制御がいるものとして true を返す
        json_result = RustGenCelltypePlugin.json_parse_result
        if json_result.length == 0 then
            return true
        end

        celltype_name = self.get_celltype.get_global_name.to_s
        if json_result[self.get_global_name.to_s]["Celltype"] == celltype_name then
            if json_result[self.get_global_name.to_s]["ExclusiveControl"] == "true" then
                return true
            end
            return false
        end
        puts "Error: JSON file does not include #{self.get_global_name.to_s}"
        return false
    end

    def check_multiple_accessed
        # JSONファイルがパースされていない場合は、保守的に true を返す
        json_result = RustGenCelltypePlugin.json_parse_result
        if json_result.length == 0 then
            return true
        end

        celltype_name = self.get_celltype.get_global_name.to_s
        if json_result[self.get_global_name.to_s]["Celltype"] == celltype_name then
            if json_result[self.get_global_name.to_s]["TaskList"].length > 1 then
                return true
            end
            return false
        end
        puts "Error: JSON file does not include #{self.get_global_name.to_s}"
        return false
    end

    # セルの構造体の初期化の先頭部につける指定子などを生成
    # 例: "#[unsafe(link_section = \".rodata\")]"
    def gen_rust_cell_structure_header_initialize_specifier file
        file.print "#[unsafe(link_section = \".rodata\")]"
    end

    # セルの構造体の初期化の先頭部を生成
    def gen_rust_cell_structure_header_initialize file

        gen_rust_cell_structure_header_initialize_specifier file

        # 属性があれば CONFIG を出す
        has_attr = self.get_celltype.get_attribute_list.any? { |attr| !attr.is_omit? }

        if has_attr then
            config_name = "Config#{camel_case(self.get_name.to_s)}"
            if is_attribute_optimization?(self.get_celltype) then
                file.print "static #{self.get_global_name.to_s.upcase}: #{get_rust_celltype_name(self.get_celltype)}<#{config_name}>"
            else
                # RAM 属性保持時（非 ZST）は、セル本体から CONFIG が消えているため、非ジェネリクスとして扱う
                file.print "static #{self.get_global_name.to_s.upcase}: #{get_rust_celltype_name(self.get_celltype)}"
            end
        else
            file.print "static #{self.get_global_name.to_s.upcase}: #{get_rust_celltype_name(self.get_celltype)}"
        end
    end

    # セル構造体の初期化ためのジェネリクス代入部を生成
    def gen_rust_cell_structure_jenerics_initialize file, callport_list, use_jenerics_alphabet
        file.print " = #{get_rust_celltype_name(self.get_celltype)} "
    end

    # セルの構造体の呼び口フィールドの初期化を生成
    def gen_rust_cell_structure_callport_initialize file, callport_list
        callport_list.each{ |port|
            if port.get_port_type == :CALL then
                callee_port_name = camel_case(snake_case(self.get_join_list.get_item(port.get_name).get_port_name.to_s))
                callee_cell_name = self.get_join_list.get_item(port.get_name).get_cell.get_global_name.to_s
                file.print "\t#{snake_case(port.get_name.to_s)}: &#{callee_port_name.upcase}FOR#{callee_cell_name.upcase},\n"
            end
        }
    end

    # セルの構造体の属性フィールドの初期化を生成
    def gen_rust_cell_structure_attribute_initialize file, plugin
        celltype = self.get_celltype
        if is_zst_optimization?(celltype) then
            file.print "\t_phantom: core::marker::PhantomData,\n"
            return
        end

        has_attr = false
        array_number = 1
        celltype.get_attribute_list.each{ |attr|
            if attr.is_omit? then
                next
            else
                has_attr = true
                # セル記述で初期化されていても，反映する
                attr_symbol = attr.get_name.to_s.to_sym
                attr_array = self.get_attr_initializer(attr_symbol)
                # 属性がポインタであるときに対応
                if attr.get_type.kind_of?( PtrType ) && attr.get_type.get_size != nil then
                    type = c_type_to_rust_type(attr.get_type).delete("[]")
                    size = nil
                    if celltype.get_attribute_list.any? { |a| a.get_name == attr.get_type.get_size.to_s.to_sym } then
                        # 属性名をサイズに使っている場合は、その属性名を使う
                        size = self.get_attr_initializer(attr.get_type.get_size.to_s.to_sym)
                    else
                        # それ以外は、size_is指定子に直接指定されている値を使う 
                        # size_is(256) のように指定されている場合
                        size = attr.get_type.get_size.to_s
                    end
                    # size = self.get_attr_initializer(attr.get_type.get_size.to_s.to_sym)
                    name = "#{self.get_global_name.upcase}ATTRARRAY#{array_number}"
                    plugin.push_pointer_array(name, type, size, attr_array)
                    file.print "\t#{attr.get_name.to_s}: &#{name},\n"
                    array_number += 1
                elsif attr.get_type.kind_of?( StructType ) then
                    # 構造体属性: 初期化子が配列ならフィールドごとに割当、
                    # それ以外（PL_EXP/C_EXP など式）の場合は式をそのまま出力する
                    if attr_array.is_a?(Array) then
                        file.print "\t#{attr.get_name.to_s}: #{c_type_to_rust_type(attr.get_type)} {\n"
                        struct_field_name = attr.get_type.get_members_decl.get_items
                        struct_field_name.zip(attr_array).each{ |field, value|
                            file.print "\t\t#{snake_case(field.get_name.to_s)}: #{value},\n"
                        }
                        file.print("},\n")
                    else
                        # 非配列（C_EXP 等）: そのまま式を埋め込む
                        file.print "\t#{attr.get_name.to_s}: #{self.get_attr_initializer(attr_symbol).to_s},\n"
                    end
                # 属性が配列であるときに対応
                elsif attr_array.is_a?(Array) then 
                    file.print "\t#{attr.get_name.to_s}: ["
                    attr_array.each{ |attr_array_item|
                        if attr_array_item == attr_array.last then
                            file.print "#{attr_array_item}"
                        else
                            file.print "#{attr_array_item}, "
                        end
                    }
                    file.print "],\n"
                else
                    file.print "\t#{attr.get_name.to_s}: #{self.get_attr_initializer(attr_symbol).to_s},\n"
                end
            end
        }
    end

    # セルの構造体の変数フィールドの初期化を生成
    def gen_rust_cell_structure_variable_initialize file
        celltype = self.get_celltype
        if celltype.get_var_list.length != 0 then
            file.print "\tvariable: &#{self.get_global_name.to_s.upcase}VAR,\n"
        end
    end

    # 変数構造体の初期化を生成
    # TODO: awkernel版のデータ構造と同じにできる
    def gen_rust_variable_structure_initialize file, plugin
        celltype = self.get_celltype
        if celltype.get_var_list.length != 0 then
            file.print "static #{self.get_global_name.to_s.upcase}VAR: Mutex<#{get_rust_celltype_name(celltype)}Var> = Mutex::new(#{get_rust_celltype_name(celltype)}Var {\n"

            self.gen_rust_variable_structure_field_initialize(file, plugin)

            file.print "});\n\n"

        end
    end

    # 変数構造体のフィールドの初期化を生成 (オーバーライドのために分離)
    def gen_rust_variable_structure_field_initialize file, plugin
        celltype = self.get_celltype
        array_number = 1
        # 変数構造体のフィールドの初期化を生成
        celltype.get_var_list.each{ |var|
            var_array = var.get_initializer
            # 変数がポインタであるときに対応
            if var.get_type.kind_of?( PtrType ) && var.get_type.get_size != nil then

                type = c_type_to_rust_type(var.get_type).delete("[]")
                size = nil
                if celltype.get_attribute_list.any? { |attr| attr.get_name == var.get_type.get_size.to_s.to_sym } then
                    # 属性名をサイズに使っている場合は、その属性名を使う
                    size = self.get_attr_initializer(var.get_type.get_size.to_s.to_sym)
                else
                    # それ以外は、size_is指定子に直接指定されている値を使う 
                    # size_is(256) のように指定されている場合
                    size = var.get_type.get_size.to_s
                end
                # size = cell.get_attr_initializer(var.get_type.get_size.to_s.to_sym)
                name = "mut #{self.get_global_name.upcase}VARARRAY#{array_number}"
                plugin.push_pointer_array(name, type, size, var_array)
                file.print "\t\t#{var.get_name.to_s}: unsafe{ &mut *core::ptr::addr_of_mut!(#{self.get_global_name.upcase}VARARRAY#{array_number}) },\n"
                array_number += 1
            elsif var.get_type.kind_of?( StructType ) then
                # 構造体属性: 初期化子が配列ならフィールドごとに割当、
                # それ以外（PL_EXP/C_EXP など式）の場合は式をそのまま出力する
                if var_array.is_a?(Array) then
                    file.print "\t#{var.get_name.to_s}: #{c_type_to_rust_type(var.get_type)} {\n"
                    struct_field_name = var.get_type.get_members_decl.get_items
                    struct_field_name.zip(var_array).each{ |field, value|
                        file.print "\t\t#{snake_case(field.get_name.to_s)}: #{value},\n"
                    }
                    file.print("\t},\n")
                else
                    # 非配列（C_EXP 等）: そのまま式を埋め込む
                    file.print "\t#{var.get_name}: #{var.get_initializer},\n"
                end
            elsif var_array.is_a?(Array) then
                # 属性が配列であるときに対応
                file.print "\t#{var.get_name}: ["
                var_array.each{ |var_array_item|
                    if var_array_item == var_array.last then
                        file.print "#{var_array_item.to_s}"
                    else
                        file.print "#{var_array_item.to_s}, "
                    end
                }
                file.print "],\n"
            else
                file.print "\t#{var.get_name}: #{var.get_initializer},\n"
            end
        }
    end

    # rodataセクションに配置するための属性を付与する
    def gen_rust_entryport_structure_initialize_specifier file
        file.print "#[unsafe(link_section = \".rodata\")]\n"
    end

    # 受け口構造体の初期化を生成
    def gen_rust_entryport_structure_initialize file
        celltype = self.get_celltype
        celltype.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then

                # 空のシグニチャの場合は、初期化を生成しない
                if port.get_signature.get_function_head_array.length == 0 then
                    next
                end

                # 受け口構造体の初期化を生成
                gen_rust_entryport_structure_initialize_specifier(file)
                config_type = self.get_rust_config_type
                if config_type then
                    # 属性を持つ場合は必ずジェネリクスを指定する
                    file.print "pub static #{port.get_name.to_s.upcase}FOR#{self.get_global_name.to_s.upcase}: #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(celltype)}<#{config_type}> = #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(celltype)} {\n"
                    file.print "\tcell: &#{self.get_global_name.to_s.upcase},\n"
                    if !is_attribute_optimization?(celltype) then
                        # RAM 属性保持時（非 ZST）は、PhantomData の初期化が必要
                        file.print "\t_phantom: core::marker::PhantomData,\n"
                    end
                else
                    file.print "pub static #{port.get_name.to_s.upcase}FOR#{self.get_global_name.to_s.upcase}: #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(celltype)} = #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(celltype)} {\n"
                    file.print "\tcell: &#{self.get_global_name.to_s.upcase},\n"
                end
                file.print "};\n\n"
            end
        }
    end

    # ex_ctrl_ref フィールドの初期化を生成
    def gen_rust_cell_structure_ex_ctrl_ref_initialize file
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ex_ctrl_ref の初期化を生成
    def gen_rust_ex_ctrl_ref_initialize file, cell
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ロックガードに Drop トレイトを実装する
    def gen_rust_impl_drop_for_lock_guard_structure file, callport_list, use_jenerics_alphabet
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

end

class Celltype
    include RustGenHelper

    def gen_rust_attribute_config file
        # 属性があれば（最適化有無に関わらず）CONFIG トレイトは生成する
        has_attr = self.get_attribute_list.any? { |attr| !attr.is_omit? }
        return if !has_attr

        celltype_name = get_rust_celltype_name(self)
        file.print "pub trait #{celltype_name}Config: 'static {\n"
        self.get_attribute_list.each do |attr|
            next if attr.is_omit?
            file.print "    const #{attr.get_name.to_s.upcase}: #{c_type_to_rust_type(attr.get_type)};\n"
        end
        file.print "}\n\n"

        # ZST 最適化を行う場合のみ、Deref 実装ヘルパーを生成する
        if is_zst_optimization?(self) then
            self.get_attribute_list.each do |attr|
                next if attr.is_omit?
                attr_name = attr.get_name.to_s
                attr_name_camel = camel_case(attr_name)
                rust_type = c_type_to_rust_type(attr.get_type)

                # ヘルパー構造体 (ZST)
                file.print "pub struct #{celltype_name}#{attr_name_camel}<CONFIG: #{celltype_name}Config>(core::marker::PhantomData<CONFIG>);\n"
                file.print "impl<CONFIG: #{celltype_name}Config> core::ops::Deref for #{celltype_name}#{attr_name_camel}<CONFIG> {\n"
                file.print "    type Target = #{rust_type};\n"
                file.print "    #[inline(always)]\n"
                file.print "    fn deref(&self) -> &#{rust_type} {\n"
                file.print "        &CONFIG::#{attr_name.upcase}\n"
                file.print "    }\n"
                file.print "}\n\n"
            end
        end

        # インスタンスごとの Config 実装 (ZST 最適化時のみ)
        if is_zst_optimization?(self) then
            file.print "// Instance Configurations\n"
            self.get_cell_list.each do |cell|
                instance_name_camel = camel_case(cell.get_name.to_s)
                file.print "pub struct Config#{instance_name_camel};\n"
                file.print "impl #{celltype_name}Config for Config#{instance_name_camel} {\n"
                self.get_attribute_list.each do |attr|
                    next if attr.is_omit?
                    # 初期値の取得
                    # eval_const2 を使ってリテラル値を取得する
                    initializer = cell.get_attr_initializer(attr.get_name)
                    val = initializer.eval_const2(nil)
                    file.print "    const #{attr.get_name.to_s.upcase}: #{c_type_to_rust_type(attr.get_type)} = #{val};\n"
                end
                file.print "}\n\n"
            end
        else
            # size_first (非 ZST) 時はセルタイプごとに共通のデフォルト Config を1つだけ生成
            file.print "// Default Configuration for Non-ZST (size_first) mode\n"
            file.print "pub struct ConfigDefault#{celltype_name};\n"
            file.print "impl #{celltype_name}Config for ConfigDefault#{celltype_name} {\n"
            self.get_attribute_list.each do |attr|
                next if attr.is_omit?
                # 実体はフィールドに保持されるため、定数値は何でも良い（トレイト定義を満たすため）
                rust_type = c_type_to_rust_type(attr.get_type)
                default_val = "0"
                if rust_type == "f64" || rust_type == "f32" then
                    default_val = "0.0"
                elsif ["bool"].include?(rust_type) then
                    default_val = "false"
                end
                file.print "    const #{attr.get_name.to_s.upcase}: #{rust_type} = #{default_val};\n"
            end
            file.print "}\n\n"
        end
    end

    # ロックガード構造体のライフタイムアノテーションが必要かどうかを返す
    # 属性最適化（定数化）が行われ、ロックガードに属性以外の要素が存在しない場合、ライフタイムは不要
    def is_lock_guard_lifetime_required?(callport_list, use_jenerics_alphabet)

        # 呼び口がある場合はライフタイムが必要
        if callport_list.length > 0 then
            return true
        end

        # 変数がある場合はライフタイムが必要
        if self.get_var_list.length > 0 then
            return true
        end

        # 属性最適化が行われない場合で、属性がある場合はライフタイムが必要 (属性への参照を持つため)
        if !is_attribute_optimization?(self) then
            self.get_attribute_list.each do |attr|
                if !attr.is_omit? then
                    return true
                end
            end
        end

        return false
    end

    # そのセルタイプの呼び口のリストを取得する
    # omit 指定子がついている場合と、関数を持たない signature が接続されている場合は除外
    def get_callport_list
        callport_list = []
        self.get_port_list.each{ |port|
            # is_omit? は signature 含めて判定している
            if port.get_port_type == :CALL && port.is_omit? == false then
                callport_list.push(port)
            end
        }
        return callport_list
    end

    # ジェネリクスに使うアルファベットのリストを生成
    def get_jenerics_alphabet_list callport_list
        jenerics_alphabet = ('T'..'Z').to_a + ('A'..'S').to_a
        use_jenerics_alphabet = []
        callport_list.each_with_index{ |callport, index|
            if check_gen_dyn_for_port(callport) == nil then
                callee_cell = callport.get_real_callee_cell
                callee_port = callport.get_real_callee_port

                callee_port_name = camel_case(snake_case(callee_port.get_name.to_s))
                callee_celltype = callee_cell.get_celltype
                callee_celltype_name = get_rust_celltype_name(callee_celltype)
                
                type_string = "#{callee_port_name}For#{callee_celltype_name}"
                config_type = callee_cell.get_rust_config_type
                if config_type then
                    type_string += "<#{config_type}>"
                end
                use_jenerics_alphabet.push(type_string)
            else
                use_jenerics_alphabet.push(check_gen_dyn_for_port(callport))
            end
        }
        return use_jenerics_alphabet
    end

    # セルの構造体の定義の先頭部を生成
    def gen_rust_cell_structure_header file, callport_list, use_jenerics_alphabet
        file.print "pub struct #{get_rust_celltype_name(self)}"

        params = []
        # 属性最適化（定数化）を行う場合のみ、CONFIG ジェネリクスをセル本体の引数に含める
        if is_attribute_optimization?(self) then
            params << "CONFIG"
        end

        if params.length > 0 then
            file.print "<#{params.join(", ")}>"
        end
    end

    # セル構造体のジェネリクスの where 句を生成
    def gen_rust_cell_structure_jenerics file, callport_list, use_jenerics_alphabet
        has_attr_optimized = is_attribute_optimization?(self)
        has_jenerics = self.get_number_of_jenerics(use_jenerics_alphabet) != 0

        if has_attr_optimized && has_jenerics then
            file.print "\nwhere\n"
            first = true
            if has_attr_optimized then
                file.print "\tCONFIG: #{get_rust_celltype_name(self)}Config"
                first = false
            end
            file.print ",\n"
        end
    end

    # use_jenerics_alphabet の実際のジェネリクスの数を取得
    # use_jenerics_alphabet は dyn が含まれている場合があるため，それを除いた数を返す
    def get_number_of_jenerics use_jenerics_alphabet
        number = 0
        use_jenerics_alphabet.each{ |alphabet|
            if alphabet[0..2] != "dyn" then
                number += 1
            end
        }
        return number
    end

    # セル構造体の呼び口フィールドの specifier を生成
    def check_rust_cell_structure_callport_specifier callport
        
    end

    # セル構造体の呼び口フィールドの定義を生成
    def gen_rust_cell_structure_callport file, callport_list, use_jenerics_alphabet
        callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|

            specifier = check_rust_cell_structure_callport_specifier callport

            if check_gen_dyn_for_port(callport) == nil then
                file.print "\t#{specifier}#{snake_case(callport.get_name.to_s)}: &'static #{alphabet},\n"
            else
                file.print "\t#{specifier}#{snake_case(callport.get_name.to_s)}: &'static (#{check_gen_dyn_for_port(callport)} + Sync + Send),\n"
            end
        end
    end

    # シングルトン最適化のための定数とユニット構造体の生成
    def gen_singleton_attribute_optimizations file
        return if !is_singleton_optimization?(self)
        
        cell = self.get_cell_list[0]
        
        # const の生成
        self.get_attribute_list.each do |attr|
            next if attr.is_omit?
            attr_symbol = attr.get_name.to_s.to_sym
            attr_value = cell.get_attr_initializer(attr_symbol)
            
            # 型の変換
            rust_type = c_type_to_rust_type(attr.get_type)
            
            # 属性名を大文字のスネークケースに変換して定数名とする
            const_name = snake_case(attr.get_name.to_s).upcase
            
            # 属性がポインタであるときに対応 (size_is 指定子がある場合など)
            if attr.get_type.kind_of?( PtrType ) && attr.get_type.get_size != nil then
                type = rust_type.delete("[]") # c_type_to_rust_type returns "[type]" for size_is
                size = nil
                if self.get_attribute_list.any? { |a| a.get_name == attr.get_type.get_size.to_s.to_sym } then
                    # 属性名をサイズに使っている場合は、その属性名を使う
                    size = cell.get_attr_initializer(attr.get_type.get_size.to_s.to_sym)
                else
                    # それ以外は、size_is指定子に直接指定されている値を使う 
                    size = attr.get_type.get_size.to_s
                end
                
                # シングルトンの時は @pointer_array を使わず直接定義
                file.print "const #{const_name}: [#{type}; #{size}] = "
                
                if attr_value.nil? then
                    if type == "f32" || type == "f64" then
                        file.print "[0.0; #{size}];\n"
                    else
                        file.print "[0; #{size}];\n"
                    end
                elsif attr_value.is_a?(Array) then
                    file.print "["
                    attr_value.each_with_index do |item, index|
                        file.print "#{item.to_s}"
                        file.print ", " if index != attr_value.length - 1
                    end
                    file.print "];\n"
                else
                    # C_EXP など。ポインタ型への本来の期待は配列リテラルだが、
                    # 式が指定されている場合はそのまま出力
                    file.print "#{attr_value.to_s};\n"
                end
            elsif attr.get_type.kind_of?( StructType ) then
                file.print "const #{const_name}: #{rust_type} = "
                # 構造体属性: 初期化子が配列ならフィールドごとに割当、
                # それ以外（PL_EXP/C_EXP など式）の場合は式をそのまま出力する
                if attr_value.is_a?(Array) then
                    file.print "#{rust_type} {\n"
                    struct_field_name = attr.get_type.get_members_decl.get_items
                    struct_field_name.zip(attr_value).each{ |field, val|
                        file.print "\t\t#{snake_case(field.get_name.to_s)}: #{val},\n"
                    }
                    file.print("\t};\n")
                else
                    # 非配列（C_EXP 等）: そのまま式を埋め込む
                    file.print "#{attr_value.to_s};\n"
                end
            # 属性が本来の配列であるときに対応
            elsif attr_value.is_a?(Array) then 
                file.print "const #{const_name}: #{rust_type} = ["
                attr_value.each_with_index do |item, index|
                    file.print "#{item.to_s}"
                    file.print ", " if index != attr_value.length - 1
                end
                file.print "];\n"
            else
                file.print "const #{const_name}: #{rust_type} = #{attr_value.to_s};\n"
            end
        end
        file.print "\n"
        
        # ユニット構造体と Deref 実装の生成
        celltype_name_camel = get_rust_celltype_name(self)
        self.get_attribute_list.each do |attr|
            next if attr.is_omit?
            attr_name_camel = camel_case(attr.get_name.to_s)
            struct_name = "Singleton#{celltype_name_camel}#{attr_name_camel}"
            const_name = snake_case(attr.get_name.to_s).upcase
            
            # 各定数に対応する Deref Target 型を決定
            target_type = c_type_to_rust_type(attr.get_type)
            
            file.print "pub struct #{struct_name};\n\n"
            file.print "impl core::ops::core::ops::Deref for #{struct_name} {\n"
            file.print "    type Target = #{target_type};\n"
            file.print "    #[inline(always)]\n"
            file.print "    fn deref(&self) -> &Self::Target {\n"
            file.print "        &#{const_name}\n"
            file.print "    }\n"
            file.print "}\n\n"
        end
    end

    # セル構造体の属性フィールドの定義を生成
    def gen_rust_cell_structure_attribute file
        # 属性最適化（定数化）を行う場合のみ、_phantom フィールドを出力する
        if is_attribute_optimization?(self) then
            file.print "\t_phantom: core::marker::PhantomData<CONFIG>,\n"
            return
        end
        
        self.get_attribute_list.each{ |attr|
            next if attr.is_omit?

            attr_type = c_type_to_rust_type(attr.get_type)
            if attr.get_type.kind_of?( PtrType ) && attr.get_type.get_size != nil then
                # ポインタ型の場合は，ポインタにする
                attr_type.prepend("&'static ")
            end
            gen_attribute_field(file, attr.get_name.to_s, attr_type)
        }
    end

    # ITRONプラグインでオーバーライドされるため、分離
    def gen_attribute_field file, attr_name, attr_type_str
        file.print "\t#{attr_name}: #{attr_type_str},\n"
    end

    # セル構造体の変数フィールドの定義を生成
    def gen_rust_cell_structure_variable file
        if self.get_var_list.length != 0 then
            file.print "\tvariable: &'static Mutex<#{get_rust_celltype_name(self)}Var>,\n"
        end
    end

    # 変数構造体の定義を生成
    def gen_rust_variable_structure file
        if self.get_var_list.length != 0 then
            file.print "pub struct #{get_rust_celltype_name(self)}Var {\n"

            # 変数構造体のフィールドの定義を生成
            self.get_var_list.each{ |var|
                var_type = c_type_to_rust_type(var.get_type)
                if var.get_type.kind_of?( PtrType ) && var.get_type.get_size != nil then
                    var_type.prepend("&'static mut ")
                end
                file.print "\tpub #{var.get_name}: #{var_type},\n"
            }

            file.print "}\n\n"
        end
    end

    # 受け口構造体の定義を生成
    def gen_rust_entry_structure file, callport_list
        # シングルトンの場合は定数化されているため、ジェネリクスを固定化する
        is_singleton = is_singleton_optimization?(self)

        self.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then
                next if port.get_signature.get_function_head_array.length == 0

                has_attr = self.get_attribute_list.any? { |attr| !attr.is_omit? }
                
                # 構造体名の生成
                struct_name = "#{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(self)}"
                
                if has_attr then
                    # 属性を持つ場合は、シングルトンであっても CONFIG ジェネリクスを持つようにする
                    file.print "pub struct #{struct_name}<CONFIG: #{get_rust_celltype_name(self)}Config> {\n"
                    if is_attribute_optimization?(self) then
                        file.print "\tpub cell: &'static #{get_rust_celltype_name(self)}<CONFIG"
                        # ここで閉じずに、後続のジェネリクス解決に任せる
                    else
                        # RAM 属性保持時（非 ZST）は、セル本体から CONFIG が消えているため、
                        # ここで CONFIG を保持し、PhantomData (private) を追加する
                        file.print "\tpub cell: &'static #{get_rust_celltype_name(self)},\n"
                        file.print "\t_phantom: core::marker::PhantomData<CONFIG>,\n"
                    end
                else
                    file.print "pub struct #{struct_name} {\n"
                    file.print "\tpub cell: &'static #{get_rust_celltype_name(self)}"
                    # ここで閉じずに、後続のジェネリクス解決に任せる
                end

                # セルタイプが持つ呼び口のジェネリクスを解決
                generics_added = false
                
                # has_attr && is_attribute_optimization? の場合で、ジェネリクスがこれ以上追加されなかった場合は閉じる
                if has_attr && is_attribute_optimization?(self) && !generics_added then
                    file.print ">"
                end
                
                # cell フィールドにカンマをつける (has_attr && !is_attribute_optimization? の場合は既に _phantom があるので不要)
                if !has_attr || is_attribute_optimization?(self) then
                    file.print ",\n"
                end
                file.print "}\n\n"
            end
        }
    end

    def gen_rust_entryport_function file, callport_list
        # セルタイプに受け口がある場合，impl を生成する
        self.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then
                sig = port.get_signature

                # 空のシグニチャの場合は、impl を生成しない
                if sig.get_function_head_array.length == 0 then
                    next
                end

                # ENTRY_PORT マーカーを出力
                port_name = snake_case(port.get_name.to_s)
                file.print "\n// #[<ENTRY_PORT>]# #{camel_case(port_name)}\n"
                file.print "//   entry port: #{camel_case(port_name)}\n"
                file.print "//   signature:  #{camel_case(snake_case(port.get_signature.get_global_name.to_s))}\n"
                file.print "// #[</ENTRY_PORT>]#\n"
                file.print "\n"

                has_attr = self.get_attribute_list.any? { |attr| !attr.is_omit? }
                if has_attr then
                    file.print "impl<CONFIG: #{get_rust_celltype_name(self)}Config> #{camel_case(snake_case(port.get_signature.get_global_name.to_s))} for #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(self)}<CONFIG> {\n\n"
                else
                    file.print "impl #{camel_case(snake_case(port.get_signature.get_global_name.to_s))} for #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(self)} {\n\n"
                end

                sig_param_str_list, _, lifetime_flag = sig.get_sig_param_str

                # 空の関数を生成
                sig.get_function_head_array.each{ |func_head|
                    # ENTRY_FUNC マーカーを出力
                    func_name = get_rust_function_name(func_head)
                    file.print "\t// #[<ENTRY_FUNC>]# #{camel_case(port_name)}_#{func_name}\n"
                    file.print "\t// #[</ENTRY_FUNC>]#\n"
                    # 関数のインライン化
                    if port.is_inline? then
                        file.print "\t#[inline]\n"
                    end
                    file.print "\tfn #{func_name}"
                    file.print"(&self"
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

                    if check_only_entryport_celltype then
                    else
                        # get_cell_ref 関数の呼び出しを生成
                        file.print "\t\tlet lg = self.cell.get_cell_ref();\n"
                    end
                    file.print "\n"
                    file.print"\t}\n"
                }

                file.print "}\n\n"
            else
            end
        }

        # POSTAMBLE マーカーを出力
        file.print "// #[<POSTAMBLE>]#\n"
        file.print "//   Put non-entry functions below.\n"
        file.print "// #[</POSTAMBLE>]#\n"
    end

    # セルタイプに受け口以外に生成する要素（呼び口、属性、変数）があるかどうかを判断する
    def check_only_entryport_celltype
        self.get_port_list.each{ |port|
            if port.get_port_type == :CALL then
                next if port.is_omit?
                return false
            end
        }
        self.get_attribute_list.each{ |attr|
            next if attr.is_omit?
            return false
        }
        if self.get_var_list.length != 0 then
            return false
        end
        return true
    end

    def gen_rust_get_cell_ref_impl file, callport_list, use_jenerics_alphabet

        file.print "impl"

        # 属性があれば CONFIG を出す
        # ただし、属性最適化（定数化）を行わない場合は構造体が非ジェネリクスなので、
        # impl ヘッダの CONFIG は後で関数のジェネリクスに移譲する
        has_attr = self.get_attribute_list.any? { |attr| !attr.is_omit? }
        is_attr_opt = is_attribute_optimization?(self)
        if has_attr && is_attr_opt then
            file.print "<CONFIG: #{get_rust_celltype_name(self)}Config>"
        end

        # impl する型を生成
        file.print " #{get_rust_celltype_name(self)}"

        # 属性最適化（定数化）を行う場合のみ、セル本体が CONFIG ジェネリクスを持つ
        if is_attribute_optimization?(self) then
            file.print "<CONFIG>"
        end

        file.print " {\n"

    end

    # get_cell_ref 関数のヘッダや引数はOSに依存するため、各OSのプラグインでオーバーライドする
    def gen_rust_get_cell_ref_header file, callport_list, use_jenerics_alphabet
        
    end

    def gen_rust_lock_guard_initialize_callport file, callport_list, use_jenerics_alphabet
        callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
            file.print "\t\t\t#{snake_case(callport.get_name.to_s)}: self.#{snake_case(callport.get_name.to_s)},\n"
        end
    end

    def gen_rust_lock_guard_initialize_attribute file
        self.get_attribute_list.each do |attr|
            if attr.is_omit? then
                next
            end
            if is_zst_optimization?(self) then
                file.print "\t\t\t#{attr.get_name}: #{get_rust_celltype_name(self)}#{camel_case(attr.get_name.to_s)}(core::marker::PhantomData),\n"
            else
                file.print "\t\t\t#{attr.get_name}: &self.#{attr.get_name},\n"
            end
        end

        has_attr = self.get_attribute_list.any? { |attr| !attr.is_omit? }
        if has_attr && !is_attribute_optimization?(self) then
            file.print "\t\t\t_phantom: core::marker::PhantomData::<ConfigDefault#{get_rust_celltype_name(self)}>,\n"
        end
    end

    # ロックガードの変数フィールドの生成はOSに依存するので、各プラグインでオーバーライドする
    def gen_rust_lock_guard_initialize_variable file
        
    end

    # ロックガードの初期化前の処理はOSに依存するので、各プラグインでオーバーライドする
    def gen_rust_process_before_lock_guard_initialize file
        
    end

    def gen_rust_get_cell_ref_body file, callport_list, use_jenerics_alphabet

        gen_rust_process_before_lock_guard_initialize file

        file.print "\t\tLockGuardFor#{get_rust_celltype_name(self)} {\n"

        gen_rust_lock_guard_initialize_callport file, callport_list, use_jenerics_alphabet
        gen_rust_lock_guard_initialize_attribute file
        gen_rust_lock_guard_initialize_variable file

        file.print "\t\t}"

    end

    # get_cell_ref 関数を生成する
    def gen_rust_get_cell_ref file, callport_list, use_jenerics_alphabet

        # セルタイプに受け口がない場合は，生成しない
        # 受け口がないならば，get_cell_ref 関数が呼ばれることは現状無いため
        self.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then
                
                gen_rust_get_cell_ref_impl file, callport_list, use_jenerics_alphabet

                gen_rust_get_cell_ref_header file, callport_list, use_jenerics_alphabet

                gen_rust_get_cell_ref_body file, callport_list, use_jenerics_alphabet
                
                file.print "\n\t}\n}\n"

                return
            end
        }
        
    end

    # implファイルのuse文を生成する（ベース実装）
    def gen_use_for_impl_file_base file
        signature_list = []
        self.get_port_list.each{ |port|
            # 空のシグニチャの場合は、use文を生成しない
            if port.get_signature.get_function_head_array.length != 0 then
                signature_list.push("#{snake_case(port.get_signature.get_global_name.to_s)}")
            end
        }
        signature_list.uniq!

        # PREAMBLE マーカーを出力
        file.print "// #[<PREAMBLE>]#\n"
        file.print "//   Don't edit the comments between #[<...>]# and #[</...>]#\n"
        file.print "//   These comments are used by tecsmerge when merging.\n"
        file.print "//\n"
        # 呼び口情報をコメントとして出力
        self.get_port_list.each{ |port|
            if port.get_port_type == :CALL then
                file.print "//   call port: #{port.get_name} signature: #{port.get_signature.get_global_name}\n"
            end
        }
        file.print "// #[</PREAMBLE>]#\n"
        file.print "\n"

        # 必ず tecs_global を use する
        #TODO: 必要なときにだけ use するようにする
        file.print "use crate::tecs_global::*;\n"

        file.print "use crate::tecs_celltype::#{snake_case(self.get_global_name.to_s)}::*;\n"

        if signature_list.length == 1 then
            file.print "use crate::tecs_signature::#{signature_list[0]}::*;\n"
        elsif signature_list.length > 1 then
            file.print "use crate::tecs_signature::{"
            signature_list.each{ |signature|
                if signature == signature_list.last then
                    file.print "#{signature}::*};\n"
                else
                    file.print "#{signature}::*, "
                end
            }
        end
    end

    # implファイルのuse文を生成する
    def gen_use_for_impl_file file
        gen_use_for_impl_file_base file
    end

    # セルタイプの呼び出し先が一意であるかどうかを判断する
    def check_gen_dyn_for_celltype

        self.get_port_list.each{ |port|
            if port.get_port_type == :CALL then
                if port.get_real_callee_cell == nil then
                    self.get_port_list.each{ |entryport|
                        if entryport.get_port_type == :ENTRY then
                            return true
                        end
                    }
                else
                    return false
                end
            end
        }

    end


    # ポートの接続先が一意であるかどうかを判断し，一意でない場合は，そのシグニチャの名前を返す -> 動的ディスパッチを適用するため
    def check_gen_dyn_for_port port
        if port.get_port_type == :CALL then
            if !port.is_cell_unique? then
                return "dyn " + port.get_signature.get_rust_signature_name
            end
        end
        # 受け口だった場合nilを返すが、この関数は実装を分離すべき
        return nil
    end

    def gen_impl_sync_send_trait file
        file.print "unsafe impl Sync for #{get_rust_celltype_name(self)} {}\n"
        file.print "unsafe impl Send for #{get_rust_celltype_name(self)} {}\n"
    end

    
    # セルタイプ構造体の ex_ctrl_ref フィールドの定義を生成
    # TODO: awkernel版のデータ構造と同じにすることで、将来的にこの関数を削除できる
    def gen_rust_cell_structure_ex_ctrl_ref file
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # Sync変数構造体の定義を生成
    def gen_rust_sync_variable_structure file
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # Syncトレイトの実装を生成
    def gen_rust_impl_sync_trait_for_sync_variable_structure file
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ロックガード構造体の定義を生成
    def gen_rust_lock_guard_structure file, callport_list, use_jenerics_alphabet
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
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

    # ロックガード構造体のヘッダーを生成
    def gen_rust_lock_guard_structure_header file, callport_list, use_jenerics_alphabet
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ロックガード構造体の呼び口への参照の定義を生成
    def gen_rust_lock_guard_structure_callport file, callport_list, use_jenerics_alphabet
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ロックガード構造体の属性への参照の定義を生成
    def gen_rust_lock_guard_structure_attribute file
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ロックガード構造体の変数への参照の定義を生成
    def gen_rust_lock_guard_structure_variable file
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ポインタ配列を生成
    def gen_pointer_array file, pointer_array
        pointer_array.each{ |pointer|
            name = pointer[0]
            type = pointer[1]
            size = pointer[2]
            initializer = pointer[3]

            file.print "static #{name}: [#{type}; #{size}] = "

            # 未初期化の場合 0 で埋める
            if initializer.nil? then
                if type == "f32" || type == "f64" then
                    file.print "[0.0; #{size}];\n"
                else
                    file.print "[0; #{size}];\n"
                end
            elsif initializer.is_a?(Array) then
                # 初期化子の数が配列のサイズと異なる場合、0で埋める
                if initializer.length != size then
                    if type == "f32" || type == "f64" then
                        file.print "[0.0; #{size}];\n"
                    else
                        file.print "[0; #{size}];\n"
                    end
                else
                    file.print "["
                    initializer.each{ |item|
                        if item == initializer.last then
                            file.print "#{item.to_s}"
                        else
                            file.print "#{item.to_s}, "
                        end
                    }
                    file.print "];\n"
                end
            end

            file.print "\n"
        }
    end

end

class Signature
    include RustGenHelper

    # シグニチャ名をRustの命名規則に変換する
    def get_rust_signature_name
        return camel_case(snake_case(self.get_global_name.to_s))
    end

    # シグニチャの引数リストを文字列にする
    def get_sig_param_str
        param_decl_list = []
        lifetime_annotation_flag = false
        # シグニチャの param_decl を取得する
        self.each_param{ |func_decl, param_decl|
            case param_decl.get_direction
            when :IN, :INOUT, :OUT
                param_decl_list.push(param_decl)
            when :SEND
                param_decl_list.push(param_decl)
                # TODO: send 引数への対応
            when :RECEIVE
                param_decl_list.push(param_decl)
                # TODO：receive 引数への対応
            end
        }

        # [out,string(len)]などのlenを削除する
        param_decl_list.each{ |param_decl|
            if param_decl.get_type.kind_of?( PtrType ) && param_decl.get_type.get_string != nil then
                param_decl_list.each_with_index{ |param_decl2, index|
                    if param_decl2.get_name.to_s == param_decl.get_type.get_string.to_s then
                        param_decl_list.delete_at(index)
                    end
                }
            end
        }

        # param_decl を文字列にする
        param_list_str =[]
        return_param_str =[]
        param_decl_list.each{ |param_decl|
            param_type = param_decl.get_type.get_type_str
            if check_lifetime_annotation_for_type(param_type) then
                lifetime_annotation_flag = true
            end
            if param_decl == "return" then
                next
            else
                case param_decl.get_direction
                when :IN
                    type_str = c_type_to_rust_type(param_decl.get_type)
                    if type_str.start_with?("&mut ") then
                       puts "Don't use &mut for [in] parameter: #{param_decl.get_name} in #{self.get_global_name}" 
                       exit(1)
                    end
                    if param_decl.get_type.kind_of?( PtrType ) then
                        param_list_str.push(", #{param_decl.get_name}: &#{type_str}")
                    else
                        param_list_str.push(", #{param_decl.get_name}: #{type_str}")
                    end
                when :INOUT
                    type_str = c_type_to_rust_type(param_decl.get_type)
                    if type_str.start_with?("&mut ") then
                        param_list_str.push(", #{param_decl.get_name}: #{type_str}")
                    else
                        param_list_str.push(", #{param_decl.get_name}: &mut #{type_str}")
                    end
                when :OUT
                    type_str = c_type_to_rust_type(param_decl.get_type)
                    if type_str.start_with?("&mut ") then
                        param_list_str.push(", #{param_decl.get_name}: #{type_str}")
                    else
                        if type_str.start_with?("&") then
                            puts "Don't use & for [out] parameter: #{param_decl.get_name} in #{self.get_global_name}" 
                            exit(1)
                        else
                            param_list_str.push(", #{param_decl.get_name}: &mut #{type_str}")
                        end
                    end
                when :SEND
                    # TODO: send 引数への対応
                    # 引数の数自体を変えないようにするために，ignore を入れる
                    param_list_str.push("ignore")
                when :RECEIVE
                    # TODO： receive 引数への対応
                    # 引数の数自体を変えないようにするために，ignore を入れる
                    param_list_str.push("ignore")
                end
            end
        }
        return param_list_str, return_param_str, lifetime_annotation_flag
    end
end


#== celltype プラグインの共通の親クラス
class RustGenCelltypePlugin < CelltypePlugin
    include RustGenHelper
    extend RustGenHelper
    
    attr_reader :plugin_arg_str
    # helper accessor for RustGenHelper
    def self.add_used_in_rust_custom_struct_list(key, value)
        @@used_in_rust_custom_struct_list[key] = value
    end

    def self.set_gen_heapless_crate_dependency(value)
        @@gen_heapless_crate_dependency = value
    end

    def self.size_first_celltypes
        @@size_first_celltypes
    end
    CLASS_NAME_SUFFIX = ""
    @@size_first_celltypes = {}
    @@b_signature_header_generated = false
    @@module_generated = false
    @@ex_ctrl_ref_id = 1
    @@json_parse_result = []
    def self.json_parse_result
        @@json_parse_result
    end
    @@main_lib_rs_cleaned = false
    @@cargo_path = "#{$gen}/../#{$target}"
    @@diff_src_and_gen = Hash.new { |hash, key| hash[key] = [] }
    @@rust_src_list = []
    @@makefile_generated = false
    @@mod_global_signatures_list = []
    @@mod_global_celltypes_list = []
    @@mod_global_impls_list = []
    @@struct_type_list = []
    # tecs_global.rs を 1 度だけ生成したかどうかを示すフラグ
    @@global_generated = false

    @@gen_heapless_crate_dependency = false
    @@const_init_catalog_loaded = false
    @@const_init_impled_custom_struct_list = Hash.new { |hash, key| hash[key] = [] }
    @@used_in_rust_custom_struct_list = Hash.new

    #celltype::     Celltype        セルタイプ（インスタンス）
    def initialize( celltype, option )
      super
      @celltype = celltype
      @plugin_arg_str = option.gsub( /\A"(.*)/, '\1' )    # 前後の "" を取り除く
      @plugin_arg_str.sub!( /(.*)"\z/, '\1' )
      @plugin_arg_str = CDLString.remove_dquote option
      @plugin_arg_list = {}
      @cell_list =[]
      @dyn_mutex_ref = false
      @mod_signatures_list = []
      @mod_celltypes_list = []
      @mod_impls_list = []
      @gen_use_global = false
      @pointer_array = [] #配列を指すポインタのリスト   [[セル名, シンボル, 名前]]

      plugin_option = @plugin_arg_str.split(",").map(&:strip)
      if plugin_option.include?("size_first") then
        @@size_first_celltypes[celltype.get_global_name] = true
      end

      require_tecsgen_lib 'lib/RustDefaultTypeChecker.rb'
      @@default_type_checker = Default.load!(File.expand_path(File.join(__dir__, 'lib', 'RustDefaultTypeList.json')))

      require 'fileutils'

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

    def push_pointer_array(name, type, size, var_array)
        @pointer_array.push([name, type, size, var_array])
    end

    def gen_use_mutex file
        file.print "use spin::Mutex;\n"
    end

    # @use_string_list に格納されている文字列を元に use 文を生成する
    def gen_use_header file
        if @celltype.get_var_list.length != 0 then
            gen_use_mutex file
        end

        # TODO: 必要な時だけ use するようにする
        # if @gen_use_global then
            file.print "use crate::tecs_global::*;\n"
        # end

        if @mod_signatures_list.length == 1 then
            file.print "use crate::tecs_signature::#{@mod_signatures_list[0]}::*;\n"
        elsif @mod_signatures_list.length > 1 then
            file.print "use crate::tecs_signature::{"
            @mod_signatures_list.each{ |mod_signature|
                if mod_signature != @mod_signatures_list.last then
                    file.print "#{mod_signature}::*, "
                else
                    file.print "#{mod_signature}::*};\n\n"
                end
            }
        end


        if @mod_celltypes_list.length == 1 then
            file.print "use crate::tecs_celltype::#{@mod_celltypes_list[0]}::*;\n"
        elsif @mod_celltypes_list.length > 1 then
            file.print "use crate::tecs_celltype::{"
            @mod_celltypes_list.each{ |mod_celltype|
                if mod_celltype != @mod_celltypes_list.last then
                    file.print "#{mod_celltype}::*, "
                else
                    file.print "#{mod_celltype}::*};\n\n"
                end
            }
        end
    end


    # tecs_celltype.rs と tecs_celltype ディレクトリを生成する
    def gen_tecs_celltype_rs
        # ディレクトリを生成する
        if File.exist?("#{$gen}/tecs_celltype") == false then
            FileUtils.mkdir_p("#{$gen}/tecs_celltype")
        end

        # tecs_celltype.rs を生成する
        tecs_celltype_rs = CFile.open("#{$gen}/tecs_celltype.rs", "w")
        @@mod_global_celltypes_list.each{ |mod_celltype|
            tecs_celltype_rs.print "pub mod #{mod_celltype};\n"
        }
        tecs_celltype_rs.close

        copy_gen_files_to_cargo "tecs_celltype.rs", nil
    end

    # tecs_signature.rs と tecs_signature ディレクトリを生成する
    def gen_tecs_signature_rs
        # ディレクトリを生成する
        if File.exist?("#{$gen}/tecs_signature") == false then
            FileUtils.mkdir_p("#{$gen}/tecs_signature")
        end

        # tecs_signature.rs を生成する
        tecs_signature_rs = CFile.open("#{$gen}/tecs_signature.rs", "w")
        @@mod_global_signatures_list.each{ |mod_signature|
            tecs_signature_rs.print "pub mod #{mod_signature};\n"
        }
        tecs_signature_rs.close

        copy_gen_files_to_cargo "tecs_signature.rs", nil
    end

    # tecs_impl.rs と tecs_impl ディレクトリを生成する
    def gen_tecs_impl_rs
        # ディレクトリを生成する
        if File.exist?("#{$gen}/tecs_impl") == false then
            FileUtils.mkdir_p("#{$gen}/tecs_impl")
        end

        @@mod_global_impls_list.uniq!

        # tecs_impl.rs を生成する
        tecs_impl_rs = CFile.open("#{$gen}/tecs_impl.rs", "w")
        @@mod_global_impls_list.each{ |mod_impl|
            tecs_impl_rs.print "pub mod #{mod_impl};\n"
        }
        tecs_impl_rs.close

        copy_gen_files_to_cargo "tecs_impl.rs", nil
    end





    # tecs_global.rs に use 文を生成する
    def gen_use_in_tecs_global_rs file
        # file.print("use heapless::String;\n")
    end

    # const定数の定義を生成する
    def gen_const_in_tecs_global_rs(file)
        root = Namespace.get_root

        traverse = lambda do |ns|
            consts = ns.instance_variable_get(:@const_decl_list) || []
            consts.each do |c|
            # ポインタ定数は Rust へ安全に落としにくいのでスキップ
            next if c.get_type.kind_of?(PtrType)

            rust_ty = c_type_to_rust_type(c.get_type)

            # tecsgen 本体と同じ評価ロジック
            val = c.get_initializer.eval_const2(nil)
            lit = val.to_s  # IntegerVal/FloatVal/BoolVal は妥当な文字列になる

            # グローバル名ベースで一意な CONST 名に
            name = c.get_global_name.to_s.gsub(/[^A-Za-z0-9_]/, "_").upcase

            file.print("pub const #{name}: #{rust_ty} = #{lit};\n")
            end
            ns.get_namespace_list.each { |child| traverse.call(child) }
        end

        file.print("\n")
        traverse.call(root)
        file.print("\n")
    end

    # オリジナル構造体、const定数の定義を tecs_global.rs に生成する
    def gen_tecs_global_rs
        # 構造体が 1 つも収集されていない場合は何もしない
        # return if @@struct_type_list.empty?

        # 重複を除去（同じタグ名で比較）
        # uniq_list = {}
        # @@struct_type_list.each do |st|
        #     uniq_list[st.get_name] = st unless uniq_list.key?(st.get_name)
        # end

        get_diff_between_gen_and_src "tecs_global.rs", nil

        # root = Namespace.get_root
        # structs = []  # Array<StructType>

        # traverse = lambda do |ns|
        #     decls = ns.instance_variable_get(:@decl_list) || []
        #     decls.each do |d|
        #         structs << d if d.kind_of?(StructType)
        #     end
        #     ns.get_namespace_list.each { |child| traverse.call(child) }
        # end

        # traverse.call(root)

        # typedef経由や無名struct由来も含めて拾いやすい

        # ファイルを生成
        require 'fileutils'
        out_path = "#{$gen}/tecs_global.rs"
        file = CFile.open(out_path, "w")

        gen_use_in_tecs_global_rs file

        gen_const_in_tecs_global_rs file

        # 事前に ConstInit カタログをロード
        unless @@const_init_catalog_loaded
            begin
                require_tecsgen_lib 'lib/RustConstInitTypeChecker.rb'
                const_catalog_path = File.join(File.dirname(__FILE__), 'lib', 'RustConstInitTypeList.json')
                ConstInit.load!(const_catalog_path)
                @@const_init_catalog_loaded = true
            rescue
                @@const_init_catalog_loaded = false
            end
        end

        @@used_in_rust_custom_struct_list.to_a.each do |struct_name, st|
            rust_name = camel_case(snake_case(st.get_name.to_s.sub(/^_+/, "")))

            file.print("#[derive(Clone)]\n")
            file.print("pub struct #{rust_name} {\n")

            st.get_members_decl.get_items.each do |m|
                field_name = snake_case(m.get_name.to_s)
                field_type = c_type_to_rust_type(m.get_type)
                file.print("    pub #{field_name}: #{field_type},\n")
            end

            file.print("}\n\n")

            # const fn const_init() の生成（入れ子構造体や Time など catalog で定義した式で初期化）
            if @@const_init_catalog_loaded
                custom_types = [rust_name]
                ok_fields = true
                field_inits = []
                st.get_members_decl.get_items.each do |m|
                    field_name = snake_case(m.get_name.to_s)
                    field_type = c_type_to_rust_type(m.get_type)
                    if @@const_init_impled_custom_struct_list[field_type] == true then
                        # カスタム構造体で const_init() が実装されている場合
                        field_inits << [field_name, "#{field_type}::const_init()"]
                    else
                        ok, expr = ConstInit.const_expr(field_type, custom_types: custom_types)
                        if ok && expr && !expr.include?('/* not const */')
                            field_inits << [field_name, expr]
                        else
                            ok_fields = false
                            break
                        end
                    end
                end
                if ok_fields
                    file.print("impl #{rust_name} {\n")
                    file.print("    pub const fn const_init() -> Self {\n")
                    file.print("        Self {\n")
                    field_inits.each do |(n, e)|
                        file.print("            #{n}: #{e},\n")
                    end
                    file.print("        }\n")
                    file.print("    }\n")
                    file.print("}\n\n")
                    @@const_init_impled_custom_struct_list[rust_name] = true
                end
            end
        end

        file.close

        # Cargo プロジェクトへコピー
        copy_gen_files_to_cargo "tecs_global.rs", nil
    end

    # TODO: Timeなど、特別扱いをする型に対して、defaultを実装する
    def gen_default_impl_for_custom_struct file, struct

    end

    # セルタイプに呼び口がある場合，その呼び口につながっているシグニチャのトレイトファイルを生成する
    def gen_trait_files celltype

        celltype.get_port_list.each{ |port|

            sig = port.get_signature
            sig_name = sig.get_global_name.to_s

            # シグニチャに関数がない場合は、トレイトファイルを生成しない
            if sig.get_function_head_array.length == 0 then
                next
            end

            puts "#{@celltype.get_global_name.to_s}: get_diff_between_gen_and_src"
            get_diff_between_gen_and_src "#{snake_case(sig_name)}.rs", "signature"

            trait_file = CFile.open( "#{$gen}/tecs_signature/#{snake_case(sig_name)}.rs", "w" )
            # gen_use_mutex trait_file

            # 必ず tecs_global を use する
            #TODO: 必要なときにだけ use するようにする
            trait_file.print "use crate::tecs_global::*;\n"

            trait_file.print "pub trait #{camel_case(snake_case(sig_name))} {\n"

            # シグニチャの引数の文字列を取得する
            param_list_str, return_param_str, lifetime_flag = sig.get_sig_param_str

            sig.get_function_head_array.each{ |func_head|
                return_flag = false
                trait_file.print "\tfn #{get_rust_function_name(func_head)}"

                # if lifetime_flag then
                #     trait_file.print("<'a>")
                # end

                # 関数の引数部分を生成
                # trait_file.print "(&'static self"
                trait_file.print "(&self"
                param_list_item = func_head.get_paramlist.get_items
                num = param_list_item.size
                num.times do
                    current_param = param_list_str.shift
                    if current_param == "ignore" then
                        next
                    elsif current_param == "return" then
                        return_flag = true
                    else
                        trait_file.print "#{current_param}"
                    end
                end
                trait_file.print ")"

                # 返り値の型がunknown,つまりvoidのときは，-> を生成しない
                if c_type_to_rust_type(func_head.get_return_type) != "unknown" then
                    trait_file.print "-> #{c_type_to_rust_type(func_head.get_return_type)}"
                end

                trait_file.print ";\n"

            }
            trait_file.print "}\n"

            trait_file.close

            # 既に Cargo プロジェクトにファイルが存在する場合、コピーは行わない
            # つまり、トレイトファイルは最適化の際に更新しない
            if File.exist?("#{@@cargo_path}/src/#{snake_case(sig_name)}.rs") == false then
                puts "#{@celltype.get_global_name.to_s}: copy #{snake_case(sig_name)}.rs to cargo\n"
                copy_gen_files_to_cargo "#{snake_case(sig_name)}.rs", "signature"
            end
        }
    end

    def check_option_main_or_lib
        plugin_option = @plugin_arg_str.split(",").map(&:strip)
        if plugin_option.include?("main") then
            return "main"
        elsif plugin_option.include?("lib") then
            return "lib"
        end

        # 何も指定されていない場合は，libを返す
        return "lib"
    end

    def gen_main_lib_rs celltype

        # main か lib かを取得
        file_name = check_option_main_or_lib

        if file_name == nil then
            return
        end

        file = CFile.open("#{$gen}/#{file_name}.rs", "w")

        gen_compile_option_in_main_lib_rs file, celltype
        gen_mod_in_main_lib_rs file, celltype
        gen_use_in_main_lib_rs file, celltype
        gen_entryport_function_in_main_lib_rs file, celltype

        file.close
    end

    # no_std や feature などのコンパイルオプションを生成する
    def gen_compile_option_in_main_lib_rs file, celltype
    end

    # main.rs もしくは lib.rs に use 文を生成する場合、この関数をオーバーライドする
    def gen_use_in_main_lib_rs file, celltype
    end

    # main.rs もしくは lib.rs にエントリーポート関数を生成する
    def gen_entryport_function_in_main_lib_rs file, celltype
    end

    # main.rs もしくは lib.rs に mod 記述を生成する
    def gen_mod_in_main_lib_rs file, celltype
        file.print "mod tecs_celltype;\n"
        file.print "mod tecs_signature;\n"
        file.print "mod tecs_impl;\n"
        file.print "mod tecs_global;\n"
    end

    # セルタイプに受け口がある場合，その受け口につながっているシグニチャなどをクラス変数とインスタンス変数に追加する
    def extract_mod_list

        @@mod_global_celltypes_list.push(snake_case(@celltype.get_global_name.to_s))

        @celltype.get_port_list.each{ |port|

            # シグニチャに関数がない場合は、mod 記述を生成しない    
            if port.get_signature.get_function_head_array.length != 0 then
                @@mod_global_signatures_list.push(snake_case(port.get_signature.get_global_name.to_s))
            end

            if port.get_port_type == :CALL then
                # シグニチャに関数がない場合は、mod 記述を生成しない
                if port.get_signature.get_function_head_array.length != 0 then
                    @mod_signatures_list.push(snake_case(port.get_signature.get_global_name.to_s))
                end
                # @@mod_global_signatures_list.push(snake_case(port.get_signature.get_global_name.to_s))
                @celltype.get_cell_list.each{ |cell|
                    @mod_celltypes_list.push(snake_case(cell.get_join_list.get_item(port.get_name).get_celltype.get_global_name.to_s))
                    # @@mod_global_celltypes_list.push(snake_case(cell.get_join_list.get_item(port.get_name).get_celltype.get_global_name.to_s))
                }
            elsif port.get_port_type == :ENTRY then
                @mod_impls_list.push(snake_case(@celltype.get_global_name.to_s) + "_impl")
                @@mod_global_impls_list.push(snake_case(@celltype.get_global_name.to_s) + "_impl")
                # @@mod_global_signatures_list.push(snake_case(port.get_signature.get_global_name.to_s))
            end
        }
    end

    # tecsflow.json をパースして、アクセスされたセルの情報を取得する
    def json_parse file_path
        require 'json'

        # ファイルが存在する場合は読み取って処理
        json_string = File.read(file_path)
        data = JSON.parse(json_string)

        accessed_cells = Hash.new { |hash, key| hash[key] = { "ExclusiveControl" => "false", "Accessed" => 0, "Celltype" => nil, "TaskList" => [], "PriorityList" => [] } }
        # 各セルのアクセス回数をカウントするためのハッシュ (現在、このアクセス回数はコード生成に必要のない情報)
        access_count = Hash.new(0)

        # すべてのセルのCelltypeを設定する
        data.each do |entry|
          accessed_cells[entry["Cell"]]["Celltype"] = entry["Celltype"]
        end

        # すべてのセルの排他制御の有無を設定する
        # tecsflow のほうで排他制御の有無は判定済み
        data.each do |entry|
            accessed_cells[entry["Cell"]]["ExclusiveControl"] = "true" if entry["ExclusiveControl"] == "true"
        end
    
        # すべてのセルのアクセス回数をカウント
        # すべてのセルのアクセスタスクリストを取得
        data.each do |entry|
          entry["Accessed"].each do |access|
            active_cell = access["ActiveCell"]
            access_count[entry["Cell"]] += 1
            # TaskListは、アクセスタスクの種類を格納する
            accessed_cells[entry["Cell"]]["TaskList"].push(active_cell).uniq!
            
            # PriorityListは、アクセスタスクの優先度の種類を格納する
            # TODO: TaskList と PriorityList は対応していないため、対応させる
            active_cell_priority = access["Priority"].to_i
            accessed_cells[entry["Cell"]]["PriorityList"].push(active_cell_priority).uniq!
          end
        end
    
        # 複数のタスクからアクセスされる場合に ExclusiveControl を true に設定
        # access_count.each do |cell, count|
        #     accessed_cells[cell]["ExclusiveControl"] = "true" if accessed_cells[cell]["TaskList"].length > 1
        #     accessed_cells[cell]["Accessed"] = count  
        # end
    
        # result = accessed_cells.map { |cell, details| { cell => details } }
    
        # return result

        # puts "#{accessed_cells}"

        return accessed_cells
    end

    # 排他制御をかけるかどうかを、セルタイプ毎に再判定する
    # ルートに近いセルに排他制御があり、かつ新しい合流が無い場合、そのセルタイプの排他制御を無効にする
    def json_parse_update celltype, json_parse_result
        return json_parse_result if celltype.is_active? == true

        celltype.get_cell_list.each{ |cell|
            celltype.get_port_list.each{ |callport|
                if callport.get_port_type == :CALL then
                    callee_cell_name = cell.get_join_list.get_item(callport.get_name).get_cell_name.to_s
                    # puts "#{cell.get_global_name.to_s} -> #{callee_cell_name}"
                    cell_accessed = json_parse_result[cell.get_global_name.to_s]["Accessed"]
                    callee_cell_accessed = json_parse_result[callee_cell_name]["Accessed"]
                    # puts "#{cell.get_global_name.to_s} -> #{callee_cell_name} : #{cell_accessed} -> #{callee_cell_accessed}"
                    # 呼び元と呼び先のセルのアクセス回数が同じ場合は排他制御がいらないため、falseに設定
                    # TODO: タスクのリストで判定するように修正
                    if cell_accessed == callee_cell_accessed then
                        json_parse_result[callee_cell_name]["ExclusiveControl"] = "false"
                    end
                end
            }
        }
        return json_parse_result
    end





    # cargo.toml の target を取得する
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

    

    

    

    # no_std のコンパイルの際に要求されるパニックハンドラを生成する
    def gen_panic_handler_in_main_lib_rs file
        # ItronrsPlugin で実装
        # TODO: 必要があればこちらでも実装する
    end

    # Cargo の新規プロジェクトを作成する
    def cargo_new_project path
        file_name = check_option_main_or_lib
        
        return if Dir.exist?(path)

        # TODO: Cargo の命名規則を考慮する必要があるが、makefile と同じ名前にしなければならない
        case file_name
        when "main"
            output = `cargo new --vcs none #{path}`
            puts output
            File.delete("#{path}/src/main.rs")
        when "lib"
            output = `cargo new --lib --vcs none #{path}`
            puts output
            File.delete("#{path}/src/lib.rs")
        else
            puts "Error: --main or --lib option is not set"
        end

        # ディレクトリを生成する
        FileUtils.mkdir_p("#{path}/src/tecs_signature")
        FileUtils.mkdir_p("#{path}/src/tecs_impl")
        FileUtils.mkdir_p("#{path}/src/tecs_celltype")

        change_cargo_toml path

        # gen_config_toml path

    end

    # Cargo.toml の設定を変更する
    def change_cargo_toml path
        # heapless クレートの依存関係を追加する
        if @@gen_heapless_crate_dependency then
            insert_text = <<~TOML
                heapless = "0.9.1"
            TOML

            lines = File.exist?(path) ? File.readlines(path, chomp: true) : []
            insert_lines = insert_text.lines.map!(&:chomp)

            # セクション判定用
            section_header_re = /^\s*\[[^\]]+\]\s*$/

            # [dependencies] の位置を探す
            deps_idx = lines.index { |l| l.strip == '[dependencies]' }

            if deps_idx
            # 依存セクションの末尾（次のセクション直前）を探す
            j = deps_idx + 1
            j += 1 while j < lines.length && lines[j] !~ section_header_re
            lines.insert(j, *insert_lines)
            else
            # セクションが無ければ末尾に新規作成
            lines << "" unless lines.empty? || lines.last.strip.empty?
            lines << "[dependencies]"
            lines.concat(insert_lines)
            end

            File.write(path, lines.join("\n"))
        end
    end

    # cargo.toml の設定を生成する
    def gen_config_toml path
        # ItromrsPlugin で実装
    end

    # 生成したファイルを Cargo にコピーする
    def copy_gen_files_to_cargo file_name, file_type

        gen_file_path = "#{$gen}/#{file_name}"
        dir_path = "#{@@cargo_path}/src"

        if file_type == "signature" then
            gen_file_path = "#{$gen}/tecs_signature/#{file_name}"
            dir_path = "#{@@cargo_path}/src/tecs_signature"
        elsif file_type == "impl" then
            gen_file_path = "#{$gen}/tecs_impl/#{file_name}"
            dir_path = "#{@@cargo_path}/src/tecs_impl"
        elsif file_type == "celltype" then
            gen_file_path = "#{$gen}/tecs_celltype/#{file_name}"
            dir_path = "#{@@cargo_path}/src/tecs_celltype"
        end

        # Cargo プロジェクトがあるかどうかと、gen ディレクトリにコピー元のファイルがあるかどうかを確認
        return if Dir.exist?(@@cargo_path) == false || File.exist?(gen_file_path) == false

        FileUtils.cp(gen_file_path, dir_path)

        # ユーザが追加した mod や use 文などの差分を、新しく生成されたファイルに追加する
        add_diff_to_new_cargo_src file_name, file_type
    end

    def change_function_definition_impl file_name
        # Determine target impl file (prefer user's Cargo project, fallback to gen)
        impl_path_cargo = "#{@@cargo_path}/src/tecs_impl/#{file_name}"
        impl_path_gen   = "#{$gen}/tecs_impl/#{file_name}"
        target_path = if File.exist?(impl_path_cargo) then impl_path_cargo elsif File.exist?(impl_path_gen) then impl_path_gen else nil end
        return if target_path.nil?

        content = File.read(target_path)

        # Helper: find all trait names that this impl file implements
        trait_names = content.scan(/^\s*impl\s+([A-Za-z0-9_]+)\s+for\s+[^\{]+\{/m).flatten.uniq
        return if trait_names.empty?

        # Helper: find a trait block "pub trait <TraitName> { ... }"
        find_trait_block = lambda do |trait_src, trait_name|
            m = trait_src.match(/pub\s+trait\s+#{trait_name}\s*\{(.*?)\}/m)
            m ? m[1] : nil
        end

        # Helper: parse fn signatures from trait block
        parse_trait_fns = lambda do |block|
            fns = []
            return fns if block.nil?
            block.scan(/fn\s+([a-zA-Z0-9_]+)\s*\(([^)]*)\)\s*(?:->\s*([^;\{]+))?\s*;/m).each do |name, args, ret|
                args_str = (args || "").strip
                ret_str = ret&.strip
                fns << { name: name, args: args_str, ret: ret_str }
            end
            fns
        end

        # Helper: locate impl block range (start_idx..end_idx) for a trait in content
        find_impl_block_range = lambda do |src, trait_name|
            impl_re = /impl\s+#{trait_name}\s+for\s+[^\{]+\{/m
            m = impl_re.match(src)
            return nil unless m
            open_brace_idx = m.end(0) - 1 # position of '{'
            depth = 0
            i = open_brace_idx
            while i < src.length
                ch = src[i]
                if ch == '{'
                    depth += 1
                elsif ch == '}'
                    depth -= 1
                    if depth == 0
                        return (m.begin(0))..i
                    end
                end
                i += 1
            end
            nil
        end

        # Helper: search for a function implementation header inside a range
        find_fn_in_impl = lambda do |src, range, fn_name|
            segment = src[range]
            m = segment&.match(/fn\s+#{fn_name}\s*\(([^)]*)\)\s*(?:->\s*([^\{]+))?\s*\{/m)
            if m
                # compute absolute indices of match
                abs_start = range.begin + m.begin(0)
                abs_end = range.begin + m.end(0)
                { start: abs_start, end: abs_end, args: m[1]&.strip, ret: m[2]&.strip }
            else
                nil
            end
        end

        # Helper: normalize signature strings for comparison (remove extra spaces)
        normalize = lambda { |s| (s || "").gsub(/\s+/, " ").strip }

        updated = false

        trait_names.each do |trait_name|
            # Find trait source file (prefer Cargo src, then gen)
            trait_file_candidates = [
                "#{@@cargo_path}/src/tecs_signature/#{snake_case(trait_name)}.rs",
                "#{$gen}/tecs_signature/#{snake_case(trait_name)}.rs"
            ]
            trait_path = trait_file_candidates.find { |p| File.exist?(p) }
            next if trait_path.nil?

            trait_src = File.read(trait_path)
            trait_block = find_trait_block.call(trait_src, trait_name)
            fn_sigs = parse_trait_fns.call(trait_block)
            next if fn_sigs.empty?

            impl_range = find_impl_block_range.call(content, trait_name)
            next if impl_range.nil?

            # We'll build insertions and replacements per function
            fn_sigs.each do |sig|
                fn_name = sig[:name]
                desired_args = sig[:args]
                desired_ret = sig[:ret]

                found = find_fn_in_impl.call(content, impl_range, fn_name)
                if found.nil?
                    # Append missing function stub before the impl block closing '}'
                    # Find closing brace of this impl block
                    closing_idx = impl_range.end
                    stub = "\n    fn #{fn_name}(#{desired_args})"
                    if desired_ret && desired_ret.size > 0
                        stub << " -> #{desired_ret}"
                    end
                    stub << " {\n        panic!(\"unimplemented stub generated by tecsgen: implement #{fn_name}\");\n    }\n"
                    content = content[0...closing_idx] + stub + content[closing_idx..-1]
                    # shift range end by inserted length
                    impl_range = (impl_range.begin)..(impl_range.end + stub.length)
                    updated = true
                else
                    # Compare args and return type; update header if different
                    if normalize.call(found[:args]) != normalize.call(desired_args) || normalize.call(found[:ret]) != normalize.call(desired_ret)
                        # Replace the header portion: from '(' to before '{'
                        header_start = content.index('(', found[:start])
                        header_end = content.index('{', found[:start])
                        if header_start && header_end
                            new_header = "(#{desired_args})"
                            if desired_ret && desired_ret.size > 0
                                new_header << " -> #{desired_ret} "
                            else
                                new_header << " "
                            end
                            content = content[0...header_start] + new_header + content[header_end..-1]
                            # Impl range might shift; recompute range for safety
                            impl_range = find_impl_block_range.call(content, trait_name) || impl_range
                            updated = true
                        end
                    end
                end
            end
        end

        if updated
            File.write(target_path, content)
        end
    end

    # src と gen の差分を取得する
    # この関数を呼び出すのは、新しいファイル（最適化後ファイルなど）を生成する前を想定している
    # TODO: 現在は、use や mod の差分のみを想定しているが、より汎用的にする場合、差分取得ライブラリなどを利用する
    def get_diff_between_gen_and_src file_name, file_type
        src_file = "#{@@cargo_path}/src/#{file_name}"
        gen_file = "#{$gen}/#{file_name}"

        if file_type == "signature" then
            src_file = "#{@@cargo_path}/src/tecs_signature/#{file_name}"
            gen_file = "#{$gen}/tecs_signature/#{file_name}"
        elsif file_type == "impl" then
            src_file = "#{@@cargo_path}/src/tecs_impl/#{file_name}"
            gen_file = "#{$gen}/tecs_impl/#{file_name}"
        elsif file_type == "celltype" then
            src_file = "#{@@cargo_path}/src/tecs_celltype/#{file_name}"
            gen_file = "#{$gen}/tecs_celltype/#{file_name}"
        end

        # puts "src_file: #{src_file}"

        if File.exist?(src_file) && File.exist?(gen_file) then
            src_text = File.read(src_file)
            gen_text = File.read(gen_file)

            # use / mod の行単位差分を収集（トップレベル宣言のみ）
            src_use_mod = File.readlines(src_file).select { |line| (s = line.strip) && (s.start_with?("use ") || s.start_with?("mod ")) }
            gen_use_mod = File.readlines(gen_file).select { |line| (s = line.strip) && (s.start_with?("use ") || s.start_with?("mod ")) }
            use_mod_diff = src_use_mod - gen_use_mod

            # use crate:: で始まる行は差分にしない (tecs_celltype や tecs_signature からの use 文などを想定)
            use_mod_diff.reject! { |line| (s = line.lstrip) && s.start_with?("use crate::") }

            enum_blocks = extract_enum_blocks(src_text)
            # gen に存在しない enum ブロックのみ保持
            enum_blocks.reject! { |blk| gen_text.include?(blk) }

            if @@diff_src_and_gen[file_name].empty? then
                @@diff_src_and_gen[file_name].concat(use_mod_diff)
                @@diff_src_and_gen[file_name].concat(enum_blocks)
            end

            # puts "diff_src_and_gen: #{@@diff_src_and_gen}"
        elsif File.exist?(src_file) && File.exist?(gen_file) == false then # Cargo を残したまま、make cleanするケース
            # 生成物に対して保持したいトップレベル宣言（use/mod 行と enum ブロック）を抽出
            src_use_mod = File.readlines(src_file).select { |line| (s = line.strip) && (s.start_with?("use ") || s.start_with?("mod ")) }
            src_text = File.read(src_file)
            enum_blocks = extract_enum_blocks(src_text)

            # use crate:: で始まる行は差分にしない (tecs_celltype や tecs_signature からの use 文などを想定)
            src_use_mod.reject! { |line| (s = line.lstrip) && s.start_with?("use crate::") }

            @@diff_src_and_gen[file_name].concat(src_use_mod)
            @@diff_src_and_gen[file_name].concat(enum_blocks)
        end
    end

    # Rust の enum（および pub enum）定義を、開始行（enum/pub enum）から
    # 最初に対応が取れる閉じ波括弧 '}' までを一塊のテキストとして抽出する
    def extract_enum_blocks(text)
        lines = text.lines
        blocks = []
        i = 0
        while i < lines.length
            line = lines[i]
            stripped = line.lstrip
            if stripped.start_with?("enum ") || stripped.start_with?("pub enum ")
                # ブロック開始を検出。ここから波括弧の対応を追う
                start_idx = i
                # 直前に連続する属性やドキュメントコメントを含める
                k = i - 1
                while k >= 0
                    prev = lines[k].rstrip
                    # 空行で打ち切り
                    break if prev.strip.empty?
                    prev_stripped = prev.lstrip
                    if prev_stripped.start_with?("#") || prev_stripped.start_with?("///") || prev_stripped.start_with?("//!")
                        start_idx = k
                        k -= 1
                        next
                    end
                    break
                end

                depth = 0
                started = false
                j = i
                while j < lines.length
                    cur = lines[j]
                    cur_stripped = cur.lstrip
                    # もし開き波括弧が見つかる前に別の enum 宣言が出現した場合、
                    # 先頭の enum 行が不完全と判断して開始位置をリセットする
                    if !started && (cur_stripped.start_with?("enum ") || cur_stripped.start_with?("pub enum "))
                        start_idx = j
                        # 直前の属性/ドキュメントを再収集
                        kk = j - 1
                        while kk >= 0
                            prev2 = lines[kk].rstrip
                            break if prev2.strip.empty?
                            prev2s = prev2.lstrip
                            if prev2s.start_with?("#") || prev2s.start_with?("///") || prev2s.start_with?("//!")
                                start_idx = kk
                                next
                            end
                            break
                        end
                    end
                    # シンプルに { と } の数を数える（文字列/コメントは考慮しない前提）
                    cur.each_char do |ch|
                        if ch == '{'
                            depth += 1
                            started = true
                        elsif ch == '}'
                            depth -= 1 if depth > 0
                        end
                    end
                    if started && depth == 0
                        # ブロック終端
                        block = lines[start_idx..j].join
                        block << "\n" unless block.end_with?("\n")
                        blocks << block
                        i = j # 外側の while の次で +1 される
                        break
                    end
                    j += 1
                end
            end
            i += 1
        end
        blocks
    end

    # 差分を Cargo の新しい生成ファイルに追加するため、この関数は Cargo へのコピー後に呼び出す
    # TODO: 現在差分は use や mod のみを想定しているが、将来的には他の差分も追加する？
    def add_diff_to_new_cargo_src file_name, file_type
        src_path = "#{@@cargo_path}/src/#{file_name}"

        if file_type == "signature" then
            src_path = "#{@@cargo_path}/src/tecs_signature/#{file_name}"
        elsif file_type == "impl" then
            src_path = "#{@@cargo_path}/src/tecs_impl/#{file_name}"
        elsif file_type == "celltype" then
            src_path = "#{@@cargo_path}/src/tecs_celltype/#{file_name}"
        end

        if File.exist?(src_path) then
            src_file = File.read(src_path)
            diff_src = @@diff_src_and_gen[file_name]

            # puts "diff_src_value: #{diff_src}"
            
            return if diff_src == nil

            diff_src.each do |diff|
                last_line = nil

                # puts "check diff: #{diff}"

                # 既に src ファイルに差分がある場合、追加しない
                next if src_file.include?(diff)

                # 差分が use / mod かを判定（enum はブロック想定）
                # TODO: もう少し厳格な判定をしてもいいかもしれない
                if diff.lstrip.start_with?("use ") then
                    # src ファイルの最後の use 文を取得
                    last_line = src_file.rindex(/^use\s+[\w:]+(\s*\*|);/)
                elsif diff.lstrip.start_with?("mod ") then
                    # src ファイルの最後の mod 文を取得
                    last_line = src_file.rindex(/^mod\s+[\w:]+(\s*\*|);/)
                elsif diff.lstrip.start_with?("enum ") || diff.lstrip.start_with?("pub enum ") then
                    # next させないための if
                else
                    # TODO: use / mod 以外の差分にも操作する場合は、ここに追加
                    # use / mod / enum 以外の場合は、追記しないため next
                    next
                end

                if last_line == nil then
                    # src ファイルに対象の宣言がない場合、差分を先頭に追加
                    src_file = "#{diff}\n#{src_file}"
                else
                    # src ファイルに対象の宣言がある場合、差分を挿入
                    insert_position = last_line + src_file[last_line..].index("\n") + 1
                    src_file.insert(insert_position, "#{diff}")
                end

                File.write(src_path, src_file)
            end
        end
    end

    def add_rust_src_list file_name
        @@rust_src_list.push(file_name)
    end

    def gen_rust_plugin_tecsgen_srcs_for_makefile
        return if @@makefile_generated

        @@makefile_generated = true

        makefile = AppFile.open("#{$gen}/Makefile.tecsgen")

        makefile.print( "# RUST_PLUGIN_SRCS: sources automatically generated by Rust plugin\n" )
        makefile.print( "RUST_PLUGIN_SRCS = \\\n" )

        makefile.print( "\t$(GEN_DIR)/../$(APPLNAME)/src/#{check_option_main_or_lib}.rs \\\n" )
        makefile.print( "\t$(GEN_DIR)/../$(APPLNAME)/src/tecs_global.rs \\\n" )
        makefile.print( "\t$(GEN_DIR)/../$(APPLNAME)/src/tecs_celltype.rs \\\n" )
        makefile.print( "\t$(GEN_DIR)/../$(APPLNAME)/src/tecs_signature.rs \\\n" )
        makefile.print( "\t$(GEN_DIR)/../$(APPLNAME)/src/tecs_impl.rs \\\n" )

        gen_extra_rust_plugin_tecsgen_srcs_for_makefile makefile

        makefile.print "# RUST_PLUGIN_SRCS terminator\n\n"

        makefile.close
    end

    # 他のRustプラグインで生成したい RUST_PLUGIN_TECSGEN_SRCS の要素
    # オーバーライドすることで、makefile の RUST_PLUGIN_SRCS に要素を追加できる
    def gen_extra_rust_plugin_tecsgen_srcs_for_makefile makefile
        
    end




    #=== tCelltype_factory.h に挿入するコードを生成する
    # file 以外の他のファイルにファクトリコードを生成してもよい
    # セルタイププラグインが指定されたセルタイプのみ呼び出される
    def gen_factory file
        if ! @celltype.is_singleton? then

        else

        end

        # return if @celltype.get_cell_list.length > 0
        
        # 最初に呼び出されたときに、一度だけ、生成するファイル
        if @@b_signature_header_generated != true then
            @@b_signature_header_generated = true
        end

        # Cargo の新規プロジェクトを作成する
        cargo_new_project @@cargo_path

        # main.rs または lib.rs の gen ファイルと src ファイルの差分を取得する
        get_diff_between_gen_and_src "#{check_option_main_or_lib}.rs", nil

        if @@main_lib_rs_cleaned != true then

            file_name = check_option_main_or_lib

            # 最適化の際、既に main もしくは lib が存在するため、一度空にして、正常に生成されるようにする
            if File.exist?("#{$gen}/#{file_name}.rs") then
                File.open("#{$gen}/#{file_name}.rs", "w") { |file| }
            else
                File.write("#{$gen}/#{file_name}.rs", "")
            end

            @@main_lib_rs_cleaned = true
        end

        # そのセルタイプの全てのセルに対して，ファイルを生成する
        # @celltype.get_cell_list.each{ |cell|
            # if cell.is_generate? then
            #     # lib.rs に mod を追加する
            #     global_file_name = cell.get_global_name
            #     global_file_name = global_file_name.to_s
            #     # new_string = global_file_name[1..-1]
            #     global_file_name = snake_case(global_file_name)
            # end

            # gen_mod_in_main_lib_rs_for_cell cell

            # gen_mod_test cell

            # file = CFile.open( "#{$gen}/#{global_file_name}.rs", "w" )

        json_file_path = "#{$gen}/tecsflow.json"
        if File.exist?(json_file_path) && File.exist?("./#{$target}.cdl") then
            cdl_time = File.mtime("./#{$target}.cdl")
            json_time = File.mtime(json_file_path)
            if cdl_time < json_time then
                if @@json_parse_result.length == 0 then
                    puts "#{@celltype.get_global_name.to_s}: json_parse"
                    @@json_parse_result = json_parse json_file_path
                    # @@json_parse_result = json_parse_update @celltype, @@json_parse_result
                else
                    # puts "#{@celltype.get_global_name.to_s}: json_parse_update"
                    # @@json_parse_result = json_parse_update @celltype, @@json_parse_result
                end
                # puts "#{@@json_parse_result}"
            else
                puts "cdl file is newer than json file"
            end
        end

        # cdlファイルのパスが取得できない場合、こちらを動かす
        if File.exist?(json_file_path) then
            if @@json_parse_result.length == 0 then
                puts "#{@celltype.get_global_name.to_s}: json_parse"
                @@json_parse_result = json_parse json_file_path
            else
            end
        end

        # puts "@@json_parse_result: #{@@json_parse_result}"
        
        puts "#{@celltype.get_global_name.to_s}: get_diff_between_gen_and_src"
        get_diff_between_gen_and_src "#{snake_case(@celltype.get_global_name.to_s)}.rs", "celltype"


        print "#{@celltype.get_global_name.to_s}: extract_mod_list\n"
        # mod記述を生成するリストを抽出する
        extract_mod_list

        # 重複を削除
        @mod_signatures_list.uniq!
        @mod_celltypes_list.uniq!
        @@mod_global_signatures_list.uniq!
        @@mod_global_celltypes_list.uniq!

        print "#{@celltype.get_global_name.to_s}: gen_tecs_celltype_rs\n"
        gen_tecs_celltype_rs

        print "#{@celltype.get_global_name.to_s}: gen_tecs_signature_rs\n"
        gen_tecs_signature_rs

        print "#{@celltype.get_global_name.to_s}: gen_tecs_impl_rs\n"
        gen_tecs_impl_rs

        print "#{@celltype.get_global_name.to_s}: get_callport_list\n"
        # そのセルタイプの呼び口のリストを取得する
        callport_list = @celltype.get_callport_list

        print "#{@celltype.get_global_name.to_s}: get_jenerics_alphabet_list\n"
        # ジェネリクスに使うアルファベットのリストを生成
        use_jenerics_alphabet = @celltype.get_jenerics_alphabet_list callport_list


        file = CFile.open( "#{$gen}/tecs_celltype/#{snake_case(@celltype.get_global_name.to_s)}.rs", "w")

        print "#{@celltype.get_global_name.to_s}: gen_use_header\n"
        gen_use_header file

        # シングルトン最適化の定数などを生成
        # gen_singleton_attribute_optimizations file, @celltype

        # 属性最適化（定数化）のトレイトやヘルパーを生成
        @celltype.gen_rust_attribute_config file

        print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_header\n"
        # セルの構造体の定義の先頭部を生成
        @celltype.gen_rust_cell_structure_header file, callport_list, use_jenerics_alphabet

        print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_jenerics\n"
        # セル構造体のジェネリクスの where 句を生成
        @celltype.gen_rust_cell_structure_jenerics file, callport_list, use_jenerics_alphabet
        
        file.print "{\n"

        print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_callport\n"
        # セル構造体の呼び口フィールドの定義を生成
        @celltype.gen_rust_cell_structure_callport file, callport_list, use_jenerics_alphabet

        print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_attribute\n"
        # セル構造体の属性フィールドの定義を生成
        @celltype.gen_rust_cell_structure_attribute file

        print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_variable\n"
        # セル構造体の変数フィールドの定義を生成
        @celltype.gen_rust_cell_structure_variable file

        print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_ex_ctrl_ref\n"
        # セル構造体の ex_ctrl_ref フィールドの定義を生成
        @celltype.gen_rust_cell_structure_ex_ctrl_ref file

        file.print "}\n\n"
        
        print "#{@celltype.get_global_name.to_s}: gen_rust_variable_structure\n"
        # 変数構造体の定義を生成
        @celltype.gen_rust_variable_structure file

        print "#{@celltype.get_global_name.to_s}: gen_rust_sync_variable_structure\n"
        # Sync変数構造体の定義を生成
        @celltype.gen_rust_sync_variable_structure file

        print "#{@celltype.get_global_name.to_s}: gen_rust_impl_sync_trait_for_sync_variable_structure\n"
        # Syncトレイトの実装を生成
        @celltype.gen_rust_impl_sync_trait_for_sync_variable_structure file

        print "#{@celltype.get_global_name.to_s}: gen_rust_entry_structure\n"
        # 受け口構造体の定義と初期化を生成
        @celltype.gen_rust_entry_structure file, callport_list

        print "#{@celltype.get_global_name.to_s}: gen_rust_entryport_structure_initialize\n"
        # ロックガード構造体の定義を生成
        @celltype.gen_rust_lock_guard_structure file, callport_list, use_jenerics_alphabet

        print "#{@celltype.get_global_name.to_s}: gen_main_lib_rs\n"
        # main.rs もしくは lib.rs に mod を追加する
        gen_main_lib_rs @celltype

        @celltype.get_cell_list.each{ |cell|

            print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_header_initialize\n"
            # セルの構造体の初期化の先頭部を生成
            cell.gen_rust_cell_structure_header_initialize file

            print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_jenerics_initialize\n"
            # セル構造体の初期化ためのジェネリクス代入部を生成
            cell.gen_rust_cell_structure_jenerics_initialize file, callport_list, use_jenerics_alphabet

            file.print "{\n"

            print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_callport_initialize\n"
            # セルの構造体の呼び口フィールドの初期化を生成
            cell.gen_rust_cell_structure_callport_initialize file, callport_list

            print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_attribute_initialize\n"
            # セルの構造体の属性フィールドの初期化を生成
            cell.gen_rust_cell_structure_attribute_initialize file, self

            print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_variable_initialize\n"
            # セルの構造体の変数フィールドの初期化を生成
            cell.gen_rust_cell_structure_variable_initialize file

            print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_ex_ctrl_ref_initialize\n"
            # ex_ctrl_ref フィールドの初期化を生成
            cell.gen_rust_cell_structure_ex_ctrl_ref_initialize file

            file.print "};\n\n"

            print "#{@celltype.get_global_name.to_s}: gen_rust_variable_structure_initialize\n"
            # 変数構造体の初期化を生成
            cell.gen_rust_variable_structure_initialize file, self

            print "#{@celltype.get_global_name.to_s}: gen_rust_ex_ctrl_ref_initialize\n"
            # ex_ctrl_ref の初期化を生成
            cell.gen_rust_ex_ctrl_ref_initialize file

            print "#{@celltype.get_global_name.to_s}: gen_rust_entryport_structure_initialize\n"
            # 受け口構造体の初期化を生成
            cell.gen_rust_entryport_structure_initialize file

        } # celltype.get_cell_list.each

        print "#{@celltype.get_global_name.to_s}: gen_pointer_array\n"
        # ポインタ配列を生成
        @celltype.gen_pointer_array(file, @pointer_array)

        print "#{@celltype.get_global_name.to_s}: gen_rust_impl_drop_for_lock_guard_structure\n"
        # ロックガードに Drop トレイトを実装する
        @celltype.gen_rust_impl_drop_for_lock_guard_structure file, callport_list, use_jenerics_alphabet

        if @celltype.check_only_entryport_celltype then
        else
            print "#{@celltype.get_global_name.to_s}: gen_rust_get_cell_ref\n"
            # get_cell_ref 関数を生成する
            @celltype.gen_rust_get_cell_ref file, callport_list, use_jenerics_alphabet
        end

        # dyn が必要かどうかを判断する
        # if check_gen_dyn_for_celltype @celltype then
        #     print "#{@celltype.get_global_name.to_s}: gen_impl_sync_send_trait\n"
        #     # Sync と Send トレイトを実装する
        #     gen_impl_sync_send_trait file, @celltype
        # end
        file.close

        print "#{@celltype.get_global_name.to_s}: gen_trait_files\n"
        # トレイトファイルを生成する
        # これは，各セルタイプの呼び口につながっているシグニチャに対してのみ，トレイトファイルを生成する
        gen_trait_files @celltype

        @celltype.get_port_list.each{ |port|

            if port.get_port_type == :ENTRY then

                puts "#{@celltype.get_global_name.to_s}: get_diff_between_gen_and_src"
                get_diff_between_gen_and_src "#{snake_case(@celltype.get_global_name.to_s)}_impl.rs", "impl"
                
                # CDLで変更されたシグニチャ定義を、ユーザコードの impl ファイルに反映する
                change_function_definition_impl "#{snake_case(@celltype.get_global_name.to_s)}_impl.rs"

                impl_file = CFile.open( "#{$gen}/tecs_impl/#{snake_case(@celltype.get_global_name.to_s)}_impl.rs", "w" )

                print "#{@celltype.get_global_name.to_s}: gen_use_for_impl_file\n"
                # implファイル用のuse文を生成
                @celltype.gen_use_for_impl_file impl_file
                
                print "#{@celltype.get_global_name.to_s}: gen_rust_entryport_function\n"
                # セルタイプに受け口がある場合，impl ファイルを生成する
                @celltype.gen_rust_entryport_function impl_file, callport_list

                impl_file.close

                # 初回の Cargo プロジェクト作成時のみコピー
                # 既にファイルが存在する場合のマージは tecsmerge --rust で Makefile から行う
                if File.exist?("#{@@cargo_path}/src/tecs_impl/#{snake_case(@celltype.get_global_name.to_s)}_impl.rs") == false then
                    puts "#{@celltype.get_global_name.to_s}: copy #{snake_case(@celltype.get_global_name.to_s)}_impl.rs to cargo\n"
                    copy_gen_files_to_cargo "#{snake_case(@celltype.get_global_name.to_s)}_impl.rs", "impl"
                end

                break
            end
        }

        # } # celltype.get_cell_list.each

        # セルタイプコードは、最適化の際に更新するため、最適化後のファイルを生成する
        puts "#{@celltype.get_global_name.to_s}: copy #{snake_case(@celltype.get_global_name.to_s)}.rs to cargo\n"
        copy_gen_files_to_cargo "#{snake_case(@celltype.get_global_name.to_s)}.rs", "celltype"

        # main.rs または lib.rs は最適化の際に更新しない <- セルタイプの度に更新するため、以下のコピーは必要
        # if File.exist?("#{@@cargo_path}/src/#{check_option_main_or_lib}.rs") == false then
            puts "#{@celltype.get_global_name.to_s}: copy #{check_option_main_or_lib}.rs to cargo\n"
            copy_gen_files_to_cargo "#{check_option_main_or_lib}.rs", nil
        # end

        # puts "#{@@diff_src_and_gen}"

        puts "#{@celltype.get_global_name.to_s}: gen_rust_plugin_tecsgen_srcs_for_makefile"
        gen_rust_plugin_tecsgen_srcs_for_makefile


        puts "#{@celltype.get_global_name.to_s}: gen_tecs_global_rs"
        gen_tecs_global_rs
    end # gen_factory

end