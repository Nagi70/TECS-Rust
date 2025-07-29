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

#== celltype プラグインの共通の親クラス
class RustGenCelltypePlugin < CelltypePlugin
    CLASS_NAME_SUFFIX = ""
    @@b_signature_header_generated = false
    @@module_generated = false
    @@ex_ctrl_ref_id = 1
    @@json_parse_result = []
    @@main_lib_rs_cleaned = false
    @@cargo_path = "#{$gen}/../#{$target}"
    @@diff_src_and_gen = Hash.new { |hash, key| hash[key] = [] }
    @@rust_src_list = []
    @@makefile_generated = false
    @@mod_global_signatures_list = []
    @@mod_global_celltypes_list = []
    @@mod_global_impls_list = []
    @@struct_type_list = []
    # tecs_struct_def.rs を 1 度だけ生成したかどうかを示すフラグ
    @@struct_def_generated = false

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
      @gen_use_struct_def = false

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

    def get_sig_param_str sig
        param_decl_list = []
        lifetime_annotation_flag = false
        # シグニチャの param_decl を取得する
        # 今回は receive が引数に存在していないからうまくいったが，引数にもしある場合は要素数がずれる．
        sig.each_param{ |func_decl, param_decl|
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
                    param_list_str.push(", #{param_decl.get_name}: &#{c_type_to_rust_type(param_decl.get_type)}")
                when :INOUT
                    param_list_str.push(", #{param_decl.get_name}: &mut #{c_type_to_rust_type(param_decl.get_type)}")
                when :OUT
                    param_list_str.push(", #{param_decl.get_name}: &mut #{c_type_to_rust_type(param_decl.get_type)}")
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

    # 正規表現を用いて，Option 型などに変換する
    def convert_rust_type_string(input)
        # 正規表現パターンの配列を定義
        # yamlファイルなどの外部ファイルを利用して，パターンの追加を簡単にしていく
        patterns = [
            [/Option__(\w+)__/, ->(type) { "Option<#{type}>" }],
            [/Option_Ref__(\w+)__/, ->(type) { "Option<& #{type}>" }],
            [/Option_Ref_mut__(\w+)__/, ->(type) { "Option<&mut #{type}>" }],
            [/Option_Ref_a_mut__(\w+)__/, ->(type) { "Option<&'a mut #{type}>" }],
            [/Ref__(\w+)__/, ->(type) { "&#{type}" }],
            [/Ref_mut__(\w+)__/, ->(type) { "&mut #{type}" }],
            [/Ref_a__(\w+)__/, ->(type) { "&'a #{type}" }],
            [/ITRONResult__empty__(\w+)__/, ->(err) { "Result<(), Error<#{err}>>" }],
            [/ITRONResult__(\w+)__(\w+)__/, ->(ok, err) { "Result<#{ok}, Error<#{err}>>" }],
            [/Result__empty__(\w+)__/, ->(err) { "Result<(), #{err}>" }],
            [/Result__(\w+)__(\w+)__/, ->(ok, err) { "Result<#{ok}, #{err}>" }],
          ]
        
          result = input.dup
          patterns.each do |pattern, conversion|
            result.gsub!(pattern) do
              conversion.call(*$~.captures)  # `$~.captures` を展開して渡す
            end
          end
      
        return result
    end
    
    # 正規表現のパターンを用いて，型にライフタイムが必要かチェックする関数
    # 正規表現のパターン以外には対応していない
    def check_lifetime_annotation_for_type str
        # 正規表現パターンの配列を定義
        patterns = [
            /Option_Ref_a_mut__(\w+)__/,
            /Ref_a__(\w+)__/,
            # 他にも必要なパターンがあれば追加
        ]

        # 各正規表現パターンとの一致を確認
        match_found = patterns.any? { |pattern| str =~ pattern }

        return match_found

    end

    # セルタイプ構造体にライフタイムアノテーションが必要かどうかを判定する関数
    def check_lifetime_annotation_for_celltype_structure celltype, callport_list

        # 呼び口は受け口構造体に繋がっており、受け口構造体は必ずライフタイムアノテーションが必要であるため、trueを返す
        if callport_list.length >= 1 then
            return true
        end

        # ライフタイムアノテーションが必要な属性があるかどうか
        celltype.get_attribute_list.each{ |attr|
            if attr.is_omit? then
                next
            else
                attr_type_name = attr.get_type.get_type_str
                if check_lifetime_annotation_for_type(attr_type_name) then
                    return true
                end
            end
        }

        # ライフタイムアノテーションが必要な変数があるかどうか
        celltype.get_var_list.each{ |var|
            var_type_name = var.get_type.get_type_str
            if check_lifetime_annotation_for_type(var_type_name) then
                return true
            end
        }

        return false
    end

    def gen_use_mutex file
        file.print "use spin::Mutex;\n"
    end

    # @use_string_list に格納されている文字列を元に use 文を生成する
    def gen_use_header file
        if @celltype.get_var_list.length != 0 then
            gen_use_mutex file
        end

        if @gen_use_struct_def then
            file.print "use crate::tecs_struct_def::*;\n"
        end

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

        # tecs_impl.rs を生成する
        tecs_impl_rs = CFile.open("#{$gen}/tecs_impl.rs", "w")
        @@mod_global_impls_list.each{ |mod_impl|
            tecs_impl_rs.print "pub mod #{mod_impl};\n"
        }
        tecs_impl_rs.close

        copy_gen_files_to_cargo "tecs_impl.rs", nil
    end

    # 宣言されている型を Rust の型に変換する
    # 現状として，int8_t, int16_t, int32_t, int64_t のみ対応
    # TODO:他の型への対応
    def c_type_to_rust_type c_type
        
        if c_type.kind_of?( IntType ) then
            # TODO: ここで符号付きかどうかを判断する
            if c_type.get_sign == :SIGNED then
                str = "i#{c_type.get_bit_size}"
            elsif c_type.get_sign == :UNSIGNED then
                str = "u#{c_type.get_bit_size}"
            else
                str = "i#{c_type.get_bit_size}"
            end
        elsif c_type.kind_of?( BoolType ) then
            str = "bool"
        elsif c_type.kind_of?( FloatType ) then
            str = "f#{c_type.get_bit_size}"
        elsif c_type.kind_of?( ArrayType ) then
            type = c_type_to_rust_type(c_type.get_type)
            subscript = c_type.get_subscript
            str = "[#{type}; #{subscript}]"
        elsif c_type.kind_of?( StructType ) then
            str = c_type.get_name.to_s
            # TODO: 構造体の定義がある場合は、その構造体の定義を生成する。
            # すべてのオリジナル構造体の定義を tecs_struct_def.rs に生成する
            @@struct_type_list.push(c_type)
            @gen_use_struct_def = true
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

                str = "heapless::String<#{string}>"

                if c_type.get_size != nil then
                    size = c_type.get_size.to_s.to_i
                    str.prepend("heapless::Vec::<")
                    str.concat(", #{size}>")
                end
            elsif c_type.get_size != nil then
                # TODO: size_is指定子のときの処理
                type = c_type_to_rust_type(c_type.get_type)
                str = "[#{type}; #{c_type.get_size}]"
            elsif c_type.get_count != nil then
                type = c_type_to_rust_type(c_type.get_type)
                str = "[#{type}; #{c_type.get_size}]"
            elsif c_type.get_max != nil then
                str = "check_max"
            else
                # ポインタの中の型に対して，もう一度 c_type_to_rust_type を呼び出す
                type = c_type_to_rust_type(c_type.get_type)
                str = type.gsub("*", "")
                str = convert_rust_type_string(str)
                if str == "void" then
                    str = "unknown"
                end
            end
        elsif c_type.kind_of?( RTypeType ) then
            str = c_type.get_type_str_inner
        else
            str = c_type.get_type_str
            str = convert_rust_type_string(str)
            if str == "void" then
                str = "unknown"
            end
        end
        return str
    end
    
    # オリジナル構造体の定義を tecs_struct_def.rs に生成する
    def gen_tecs_struct_def_rs
        # 構造体が 1 つも収集されていない場合は何もしない
        return if @@struct_type_list.empty?

        # 重複を除去（同じタグ名で比較）
        uniq_list = {}
        @@struct_type_list.each do |st|
            uniq_list[st.get_name] = st unless uniq_list.key?(st.get_name)
        end

        # ファイルを生成
        require 'fileutils'
        out_path = "#{$gen}/tecs_struct_def.rs"
        file = CFile.open(out_path, "w")

        uniq_list.each_value do |st|
            rust_name = camel_case(snake_case(st.get_name.to_s.sub(/^_+/, "")))
            file.print("pub struct #{rust_name} {\n")

            st.get_members_decl.get_items.each do |m|
                field_name = snake_case(m.get_name.to_s)
                field_type = c_type_to_rust_type(m.get_type)
                file.print("    pub #{field_name}: #{field_type},\n")
            end

            file.print("}\n\n")
        end

        file.close

        # Cargo プロジェクトへコピー（トップレベルなので file_type=nil）
        copy_gen_files_to_cargo "tecs_struct_def.rs", nil
    end

    # セルタイプに呼び口がある場合，その呼び口につながっているシグニチャのトレイトファイルを生成する
    def gen_trait_files celltype

        celltype.get_port_list.each{ |port|

            sig = port.get_signature
            sig_name = sig.get_global_name.to_s

            puts "#{@celltype.get_global_name.to_s}: get_diff_between_gen_and_src"
            get_diff_between_gen_and_src "#{snake_case(sig_name)}.rs", "signature"

            # gen_mod_in_main_lib_rs_for_signature sig
            trait_file = CFile.open( "#{$gen}/tecs_signature/#{snake_case(sig_name)}.rs", "w" )
            # gen_use_mutex trait_file

            if @gen_use_struct_def then
                trait_file.print "use crate::tecs_struct_def::*;\n"
            end

            trait_file.print "pub trait #{camel_case(snake_case(sig_name))} {\n"

            # シグニチャの引数の文字列を取得する
            param_list_str, return_param_str, lifetime_flag = get_sig_param_str sig

            sig.get_function_head_array.each{ |func_head|
                return_flag = false
                trait_file.print "\tfn #{get_rust_function_name(func_head)}"

                if lifetime_flag then
                    trait_file.print("<'a>")
                end

                # 関数の引数部分を生成
                trait_file.print "(&'static self"
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

        # if file_name != nil then
        #     # File.write("#{$gen}/#{file_name}.rs", "") unless File.exist?("#{$gen}/#{file_name}.rs")
        #     lib_file = File.read("#{$gen}/#{file_name}.rs")
        #     last_mod_line = lib_file.rindex(/^mod\s+\w+;/)
            
        #     new_mods = ["mod #{snake_case(celltype.get_global_name.to_s)};\n"]

        #     @celltype.get_port_list.each{ |port|
        #         if port.get_port_type == :ENTRY then
        #             # lib_file.print "mod #{snake_case(celltype.get_global_name.to_s)}_impl;\n"
        #             new_mods.push("mod #{snake_case(celltype.get_global_name.to_s)}_impl;\n")
        #             break
        #         end
        #     }

        #     # mod記述の最後に新しいmodを挿入
        #     if last_mod_line
        #         insert_position = last_mod_line + lib_file[last_mod_line..].index("\n") + 1
        #         new_mods.each do |mod|
        #             next if lib_file.include?(mod)
        #             lib_file.insert(insert_position, "#{mod}")
        #             insert_position += "#{mod}".length
        #         end
        #     else
        #         # もしmod記述が見つからなければ、ファイルの末尾に追加
        #         lib_file << new_mods.join("\n")
        #     end

        #     File.write("#{$gen}/#{file_name}.rs", lib_file)
        # end
    end

    def gen_mod_in_main_lib_rs_for_signature signature

        # file_name = check_option_main_or_lib

        # if file_name != nil then
        #     # File.write("#{$gen}/#{file_name}.rs", "") unless File.exist?("#{$gen}/#{file_name}.rs")
        #     lib_file = File.read("#{$gen}/tecs_signature.rs")
        #     return if lib_file.include?("mod #{snake_case(signature.get_global_name.to_s)};")

        #     last_mod_line = lib_file.rindex(/^mod\s+\w+;/)

        #     # mod記述の最後に新しいmodを挿入
        #     if last_mod_line
        #         insert_position = last_mod_line + lib_file[last_mod_line..].index("\n") + 1
        #         lib_file.insert(insert_position, "mod #{snake_case(signature.get_global_name.to_s)};\n")
        #     else
        #         # もしmod記述が見つからなければ、ファイルの末尾に追加
        #         lib_file << "mod #{snake_case(signature.get_global_name.to_s)};"
        #     end

        #     File.write("#{$gen}/#{file_name}.rs", lib_file)
        # end
    end

    # セルタイプに受け口がある場合，その受け口につながっているシグニチャなどをクラス変数とインスタンス変数に追加する
    def extract_mod_list
        # @use_string_list.push("kernel_obj_ref")
        # セルタイプに受け口がある場合，use 文を生成する
        @celltype.get_port_list.each{ |port|
            if port.get_port_type == :CALL then
                @mod_signatures_list.push(snake_case(port.get_signature.get_global_name.to_s))
                @@mod_global_signatures_list.push(snake_case(port.get_signature.get_global_name.to_s))
                @celltype.get_cell_list.each{ |cell|
                    # cellport = cell.get_real_port(port.get_name)
                    # print "cellport: #{cellport.get_name}\n"
                    # callee_cellport = cellport.get_real_callee_port
                    # print "callee_cellport: #{callee_cellport}\n"
                    # temp_port = port.get_real_callee_port
                    # print "temp_port: #{temp_port}\n"
                    # temp = port.get_real_callee_cell
                    # print "port: #{port.get_name}\n"
                    # print "temp: #{temp}\n"
                    # join_list = cell.get_join_list
                    # print "join_list: #{join_list}\n"
                    # item = join_list.get_item(port.get_name)
                    # print "item: #{item}\n"
                    # port_name = item.get_port_global_name
                    # print "port_name: #{port_name}\n"
                    # join_cell_name = item.get_cell_name
                    # print "join_cell_name: #{join_cell_name}\n"
                    # join_name = item.get_name
                    # print "join_name: #{join_name}\n"
                    # join_cell_global_name = item.get_cell_global_name
                    # print "join_cell_global_name: #{join_cell_global_name}\n"
                    # join_celltype = cell.get_join_list.get_item(port.get_name).get_celltype
                    # print "join_celltype: #{join_celltype.get_global_name}\n"
                    # print "join_portname: #{cell.get_join_list.get_item(port.get_name).get_port_name}\n"
                    # join_cell = item.get_cell
                    # print "join_cell: #{join_cell.get_name}\n"
                    # @use_string_list.push("#{snake_case(port.get_real_callee_cell.get_celltype.get_global_name.to_s)}")
                    @mod_celltypes_list.push(snake_case(cell.get_join_list.get_item(port.get_name).get_celltype.get_global_name.to_s))
                    @@mod_global_celltypes_list.push(snake_case(cell.get_join_list.get_item(port.get_name).get_celltype.get_global_name.to_s))
                }
            elsif port.get_port_type == :ENTRY then
                @mod_impls_list.push(snake_case(@celltype.get_global_name.to_s) + "_impl")
                @@mod_global_impls_list.push(snake_case(@celltype.get_global_name.to_s) + "_impl")
                @@mod_global_signatures_list.push(snake_case(port.get_signature.get_global_name.to_s))
            end
        }
    end

    # そのセルタイプの呼び口のリストを取得する
    # omit 指定子がついている場合と、関数を持たない signature が接続されている場合は除外
    def get_callport_list
        callport_list = []
        @celltype.get_port_list.each{ |port|
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
        # 呼び口の数と等しくする
        # if callport_list.length != 0 then
        #     use_jenerics_alphabet = jenerics_alphabet[0..callport_list.length-1]
        # end
        callport_list.each_with_index{ |callport, index|
            if check_gen_dyn_for_port(callport) == nil then
                use_jenerics_alphabet.push(jenerics_alphabet[index])
            else
                use_jenerics_alphabet.push(check_gen_dyn_for_port(callport))
            end
        }
        return use_jenerics_alphabet
    end

    def get_rust_celltype_name celltype
        return camel_case(snake_case(celltype.get_global_name.to_s))
    end

    def get_rust_function_name func_head
        return snake_case(func_head.get_name.to_s)
    end

    # セルの構造体の定義の先頭部を生成
    def gen_rust_cell_structure_header file, celltype, callport_list, use_jenerics_alphabet
        file.print "pub struct #{get_rust_celltype_name(celltype)}"
        if check_only_entryport_celltype(celltype) then
        else
            # セルタイプ構造体にライフタイムアノテーションが必要かどうか判定する(必要 -> 呼び口を持っている)
            # TODO: ライフタイムアノテーションの判定は厳格にする必要がある
            if check_lifetime_annotation_for_celltype_structure(celltype, callport_list) then
                file.print "<'a"
                # use_jenerics_alphabet と callport_list の要素数が等しいことを前提としている
                callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
                    if check_gen_dyn_for_port(callport) == nil then
                        file.print ", #{alphabet}"
                    end
                end
                file.print ">"
            end
        end
    end

    def get_rust_signature_name signature
        return camel_case(snake_case(signature.get_global_name.to_s))
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

    # セル構造体のジェネリクスの where 句を生成
    def gen_rust_cell_structure_jenerics file, callport_list, use_jenerics_alphabet
        # if use_jenerics_alphabet.length != 0 then
        #     file.print "where\n"
        # end
        if get_number_of_jenerics(use_jenerics_alphabet) != 0 then
            file.print "\nwhere\n"
        end

        callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
            if check_gen_dyn_for_port(callport) == nil then
                file.print "\t#{alphabet}: #{get_rust_signature_name(callport.get_signature)},\n"
            end
        end
    end

    # セル構造体の呼び口フィールドの定義を生成
    def gen_rust_cell_structure_callport file, callport_list, use_jenerics_alphabet
        callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
            if check_gen_dyn_for_port(callport) == nil then
                file.print "\t#{snake_case(callport.get_name.to_s)}: &'a #{alphabet},\n"
            else
                file.print "\t#{snake_case(callport.get_name.to_s)}: &'a (#{check_gen_dyn_for_port(callport)} + Sync + Send),\n"
            end
        end
    end

    # セル構造体の属性フィールドの定義を生成
    def gen_rust_cell_structure_attribute file, celltype
        celltype.get_attribute_list.each{ |attr|
            if attr.is_omit? then
                next
            else
                file.print "\t#{attr.get_name.to_s}: #{c_type_to_rust_type(attr.get_type)},\n"
            end
        }
    end

    # セル構造体の変数フィールドの定義を生成
    def gen_rust_cell_structure_variable file, celltype
        if celltype.get_var_list.length != 0 then
            file.print "\tvariable: &'a Mutex<#{get_rust_celltype_name(celltype)}Var"
            # ライフタイムアノテーションの生成部
            # TODO：ライフタイムについては，もう少し厳格にする必要がある
            celltype.get_var_list.each{ |var|
                var_type_name = var.get_type.get_type_str
                if check_lifetime_annotation_for_type(var_type_name) then
                    file.print "<'a>"
                    break
                end
            }
            file.print ">,\n"
        end
    end

    # 変数構造体の定義を生成
    def gen_rust_variable_structure file, celltype
        if celltype.get_var_list.length != 0 then
            file.print "pub struct #{get_rust_celltype_name(celltype)}Var" 
            # ライフタイムアノテーションの生成部
            # TODO：ライフタイムについては，もう少し厳格にする必要がある
            celltype.get_var_list.each{ |var|
                var_type_name = var.get_type.get_type_str
                if check_lifetime_annotation_for_type var_type_name then
                    file.print "<'a>"
                    break
                end
            }
            file.print "{\n"

            # 変数構造体のフィールドの定義を生成
            celltype.get_var_list.each{ |var|
                file.print "\tpub #{var.get_name}: #{c_type_to_rust_type(var.get_type)},\n"
            }

            file.print "}\n\n"
        end
    end

    # セルの構造体の初期化の先頭部を生成
    def gen_rust_cell_structure_header_initialize file, cell
        file.print "#[link_section = \".rodata\"]\n"
        file.print "static #{cell.get_global_name.to_s.upcase}: #{get_rust_celltype_name(cell.get_celltype)}"
    end

    # セル構造体のジェネリクス代入部を生成
    def gen_rust_cell_structure_jenerics_initialize file, cell, callport_list, use_jenerics_alphabet
        # if callport_list.length != 0 then
        #     file.print "<"
        # end
        if get_number_of_jenerics(use_jenerics_alphabet) != 0 then
            file.print "<"
        end
        # ジェネリクスを代入
        callport_list.each_with_index do |callport, index|
            if check_gen_dyn_for_port(callport) == nil then
                callee_port_name = camel_case(snake_case(cell.get_join_list.get_item(callport.get_name).get_port_name.to_s))
                callee_celltype_name = camel_case(snake_case(cell.get_join_list.get_item(callport.get_name).get_celltype.get_global_name.to_s))
                if index == callport_list.length - 1
                    # 最後の要素の処理
                    file.print "#{callee_port_name}For#{callee_celltype_name}>"
                else
                    # 通常の要素の処理
                    file.print "#{callee_port_name}For#{callee_celltype_name}, "
                end
            end
        end # port_list.each_with_index
        file.print " = #{get_rust_celltype_name(cell.get_celltype)} "
    end

    # セルの構造体の呼び口フィールドの初期化を生成
    def gen_rust_cell_structure_callport_initialize file, cell, callport_list
        callport_list.each{ |port|
            if port.get_port_type == :CALL then
                callee_port_name = camel_case(snake_case(cell.get_join_list.get_item(port.get_name).get_port_name.to_s))
                callee_cell_name = cell.get_join_list.get_item(port.get_name).get_cell.get_global_name.to_s
                file.print "\t#{snake_case(port.get_name.to_s)}: &#{callee_port_name.upcase}FOR#{callee_cell_name.upcase},\n"
            end
        }
    end

    # セルの構造体の属性フィールドの初期化を生成
    def gen_rust_cell_structure_attribute_initialize file, celltype, cell
        celltype.get_attribute_list.each{ |attr|
            if attr.is_omit? then
                next
            else
                # セル記述で初期化されていても，反映する
                attr_symbol = attr.get_name.to_s.to_sym
                attr_array = cell.get_attr_initializer(attr_symbol)
                # 属性が配列であるときに対応
                if attr_array.is_a?(Array) then
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
                    file.print "\t#{attr.get_name.to_s}: #{cell.get_attr_initializer(attr_symbol).to_s},\n"
                end
            end
        }
    end

    # セルの構造体の変数フィールドの初期化を生成
    def gen_rust_cell_structure_variable_initialize file, celltype ,cell
        if celltype.get_var_list.length != 0 then
            file.print "\tvariable: &#{cell.get_global_name.to_s.upcase}VAR,\n"
        end
    end

    # 変数構造体の初期化を生成
    # TODO: awkernel版のデータ構造と同じにできる
    def gen_rust_variable_structure_initialize file, cell
        if @celltype.get_var_list.length != 0 then
            file.print "static #{cell.get_global_name.to_s.upcase}VAR: Mutex<#{get_rust_celltype_name(cell.get_celltype)}Var> = Mutex::new(#{get_rust_celltype_name(cell.get_celltype)}Var {\n"

            # 変数構造体のフィールドの初期化を生成
            @celltype.get_var_list.each{ |var|
                var_array = var.get_initializer
                # 属性が配列であるときに対応
                if var_array.is_a?(Array) then
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

            file.print "});\n\n"

        end
    end

    # 受け口構造体の定義を生成
    def gen_rust_entry_structure file, celltype, callport_list
        celltype.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then
                # 受け口構造体の定義を生成
                file.print"pub struct #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(celltype)}"
                file.print "<'a>"
                file.print "{\n"
                # 受け口を持っているセルの参照をフィールドとして生成
                file.print "\tpub cell: &'a #{get_rust_celltype_name(celltype)}"
                if check_only_entryport_celltype(celltype) then
                else
                    # セルタイプ構造体にライフタイムアノテーションが必要かどうか
                    if check_lifetime_annotation_for_celltype_structure(celltype, callport_list) then
                        file.print "<'a"
                        callport_list.each{ |cport|
                            if check_gen_dyn_for_port(cport) == nil then
                                # entryport_name = camel_case(snake_case(cell.get_join_list.get_item(port.get_name).get_port_name.to_s))
                                entryport_name = camel_case(snake_case(cport.get_real_callee_port.get_name.to_s))
                                # call_celltype_name = camel_case(snake_case(cell.get_join_list.get_item(port.get_name).get_celltype.get_global_name.to_s))
                                call_celltype_name = camel_case(snake_case(cport.get_real_callee_cell.get_celltype.get_global_name.to_s))
                                file.print ", #{entryport_name}For#{call_celltype_name}<'a>"
                            end   
                        }
                        file.print ">"
                    end
                end
                file.print ",\n"
                file.print "}\n\n"
            end
        }
    end

    # 受け口構造体の初期化を生成
    def gen_rust_entryport_structure_initialize file, celltype, cell
        celltype.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then
                # 受け口構造体の初期化を生成
                # 一つの受け口構造体がもつセルは１つ
                file.print "#[link_section = \".rodata\"]\n"
                file.print "pub static #{port.get_name.to_s.upcase}FOR#{cell.get_global_name.to_s.upcase}: #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(celltype)} = #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(celltype)} {\n"
                file.print "\tcell: &#{cell.get_global_name.to_s.upcase},\n"
                file.print "};\n\n"
            end
        }
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
    # セルタイプに受け口以外の要素があるかどうかを判断する
    def check_only_entryport_celltype celltype
        celltype.get_port_list.each{ |port|
            if port.get_port_type == :CALL then
                # if check_gen_dyn_for_port(port) != nil then
                #     next
                # end
                return false
            end
        }
        if celltype.get_attribute_list.length != 0 then
            return false
        end
        if celltype.get_var_list.length != 0 then
            return false
        end
        return true
    end

    # get_cell_ref 関数を生成する
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
                        # file.print "'a, "
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
                    return_tuple_type_list.push("&Mutex<#{get_rust_celltype_name(celltype)}Var")
                    celltype.get_var_list.each{ |var|
                        var_type_name = var.get_type.get_type_str
                        if check_lifetime_annotation_for_type(var_type_name) then
                            return_tuple_type_list[-1].concat("<'a>")
                            break
                        end
                    }
                    return_tuple_type_list[-1].concat(">")
                    return_tuple_list.push("&self.variable")
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

                file.print "\t\t"
                
                if return_tuple_list.length != 1 then
                    file.print "("
                end

                # 返り値のタプルを生成
                return_tuple_list.each_with_index do |return_tuple, index|
                    if index == return_tuple_list.length - 1 then
                        file.print "#{return_tuple}"
                        break
                    end
                    file.print "#{return_tuple}, "
                end

                if return_tuple_list.length != 1 then
                    file.print ")"
                end
                
                file.print"\n\t}\n}\n"
                # get_cell_ref 関数を生成するのは1回だけでいいため，break する
                break

            end # if port.get_port_type == :ENTRY then
        } # celltype.get_port_list.each
    end

    # implファイルのuse文を生成する
    def gen_use_for_impl_file file, celltype
        signature_list = []
        celltype.get_port_list.each{ |port|
            signature_list.push("#{snake_case(port.get_signature.get_global_name.to_s)}")
        }
        signature_list.uniq!
        # implファイルに対して、排他制御に関するuse文は生成する必要がない
        # if @celltype.get_var_list.length != 0 then
        #     gen_use_mutex file
        # end

        if @gen_use_struct_def then
            file.print "use crate::tecs_struct_def::*;\n"
        end

        file.print "use crate::tecs_signature::#{snake_case(celltype.get_global_name.to_s)}::*;\n"

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

        # file.print "use crate::{"
        # signature_list.each{ |signature|
        #     if signature == signature_list.last then
        #         file.print "#{signature}::*"
        #     else
        #         file.print "#{signature}::*, "
        #     end
        # }
        # file.print "};\n\n"
    end

    # セルタイプの呼び出し先が一意であるかどうかを判断する
    def check_gen_dyn_for_celltype celltype

        celltype.get_port_list.each{ |port|
            if port.get_port_type == :CALL then
                if port.get_real_callee_cell == nil then
                    celltype.get_port_list.each{ |entryport|
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

    # ポートの接続先が一意であるかどうかを判断し，一意でない場合は，そのシグニチャの名前を返す
    def check_gen_dyn_for_port port
        if port.get_port_type == :CALL then
            if port.get_real_callee_port == nil then  # TODO：joinではなくportで接続先を確認しているため、より厳密なチェックが必要になる可能性がある 
                # 呼び先が一意でない かつ 受け口を持っている場合に動的ディスパッチ
                port.get_celltype.get_port_list.each{ |entryport|
                    if entryport.get_port_type == :ENTRY then
                        return "dyn " + get_rust_signature_name(port.get_signature)
                    end
                }
                return nil
            else
                return nil
            end
        else
            # 受け口だった場合nilを返すが、この関数は実装を分離すべき
            return nil
        end
    end

    def gen_impl_sync_send_trait file, celltype
        file.print "unsafe impl Sync for #{get_rust_celltype_name(celltype)}<'_> {}\n"
        file.print "unsafe impl Send for #{get_rust_celltype_name(celltype)}<'_> {}\n"
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

    # 引数のセルが複数のタスクからアクセスされているかどうかを判断する
    def check_exclusive_control_for_cell cell
        # JSONファイルがパースされていない場合は、排他制御がいるものとして true を返す
        if @@json_parse_result.length == 0 then
            return true
        end

        celltype = cell.get_celltype.get_global_name.to_s
        if @@json_parse_result[cell.get_global_name.to_s]["Celltype"] == celltype then
            if @@json_parse_result[cell.get_global_name.to_s]["ExclusiveControl"] == "true" then
                return true
            end
            return false
        end
        puts "Error: JSON file does not include #{cell.get_global_name.to_s}"
        return false
    end

    def check_multiple_accessed_for_cell cell
        # JSONファイルがパースされていない場合は、保守的に true を返す
        if @@json_parse_result.length == 0 then
            return true
        end

        celltype = cell.get_celltype.get_global_name.to_s
        if @@json_parse_result[cell.get_global_name.to_s]["Celltype"] == celltype then
            if @@json_parse_result[cell.get_global_name.to_s]["TaskList"].length > 1 then
                return true
            end
            return false
        end
        puts "Error: JSON file does not include #{cell.get_global_name.to_s}"
        return false
    end

    # 引数のセルタイプの ex_ctrl_ref に動的ディスパッチが必要かどうかを判断し、いる場合は dyn を、いらない場合は、ダミーかどうかを返す
    def check_gen_dyn_for_ex_ctrl_ref celltype
        dyn_check_results = celltype.get_cell_list.map { |cell| check_exclusive_control_for_cell(cell) }
        
        if dyn_check_results.all?(true) then
            return "no_dummy"
        elsif dyn_check_results.all?(false) then
            return "dummy"
        else
            return "dyn"
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

    # セルタイプ構造体の ex_ctrl_ref フィールドの定義を生成
    # TODO: awkernel版のデータ構造と同じにすることで、将来的にこの関数を削除できる
    def gen_rust_cell_structure_ex_ctrl_ref file, celltype
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # Sync変数構造体の定義を生成
    def gen_rust_sync_variable_structure file, celltype
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # Syncトレイトの実装を生成
    def gen_rust_impl_sync_trait_for_sync_variable_structure file, celltype
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ロックガード構造体の定義を生成
    def gen_rust_lock_guard_structure file, celltype, callport_list, use_jenerics_alphabet
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
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
    end

    # ロックガード構造体のヘッダーを生成
    def gen_rust_lock_guard_structure_header file, celltype, callport_list, use_jenerics_alphabet
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ロックガード構造体の呼び口への参照の定義を生成
    def gen_rust_lock_guard_structure_callport file, callport_list, use_jenerics_alphabet
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ロックガード構造体の属性への参照の定義を生成
    def gen_rust_lock_guard_structure_attribute file, celltype
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ロックガード構造体の変数への参照の定義を生成
    def gen_rust_lock_guard_structure_variable file, celltype
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ex_ctrl_ref フィールドの初期化を生成
    def gen_rust_cell_structure_ex_ctrl_ref_initialize file, celltype, cell
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ex_ctrl_ref の初期化を生成
    def gen_rust_ex_ctrl_ref_initialize file, cell
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
    end

    # ロックガードに Drop トレイトを実装する
    def gen_rust_impl_drop_for_lock_guard_structure file, celltype, callport_list, use_jenerics_alphabet
        # ItronrsPlugin で実装
        # TODO: spinクレート版を実装する場合はこの関数を使う
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
        # ItronrsPlugin で実装
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
            src_line = File.readlines(src_file)
            gen_line = File.readlines(gen_file)

            # src のみに存在する行を取得
            diff_src = src_line - gen_line

            # puts "diff_src: #{diff_src}"

            # 既にハッシュの中に値がある場合は、差分を追加しない（一度の差分取得で十分）
            if @@diff_src_and_gen[file_name].empty? then
                @@diff_src_and_gen[file_name].concat(diff_src)
            end

            # puts "diff_src_and_gen: #{@@diff_src_and_gen}"
        elsif File.exist?(src_file) && File.exist?(gen_file) == false then # Cargo を残したまま、make cleanするケース
            src_line = File.readlines(src_file)
            src_line = src_line.select { |line| line.strip.start_with?("mod ", "use ") }
            @@diff_src_and_gen[file_name].concat(src_line)
        end
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

                # 差分が use か mod かを判定
                # TODO: もう少し厳格な判定をしてもいいかもしれない
                if diff.include?("use ") then
                    # src ファイルの最後の use 文を取得
                    last_line = src_file.rindex(/^use\s+[\w:]+(\s*\*|);/)
                elsif diff.include?("mod ") then
                    # src ファイルの最後の mod 文を取得
                    last_line = src_file.rindex(/^mod\s+[\w:]+(\s*\*|);/)
                else
                    # TODO: use と mod 以外の差分にも操作する場合は、ここに追加
                    next
                end

                if last_line == nil then
                    # src ファイルに use や mod がない場合、差分を先頭に追加
                    src_file = "#{diff}\n#{src_file}"
                else
                    # src ファイルに use や mod がある場合、差分を挿入
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
        # セルタイプに受け口がある場合，use 文を生成する
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
        callport_list = get_callport_list

        print "#{@celltype.get_global_name.to_s}: get_jenerics_alphabet_list\n"
        # ジェネリクスに使うアルファベットのリストを生成
        use_jenerics_alphabet = get_jenerics_alphabet_list callport_list


        file = CFile.open( "#{$gen}/tecs_celltype/#{snake_case(@celltype.get_global_name.to_s)}.rs", "w")

        print "#{@celltype.get_global_name.to_s}: gen_use_header\n"
        gen_use_header file

        print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_header\n"
        # セルの構造体の定義の先頭部を生成
        gen_rust_cell_structure_header file, @celltype, callport_list, use_jenerics_alphabet

        print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_jenerics\n"
        # セル構造体のジェネリクスの where 句を生成
        gen_rust_cell_structure_jenerics file, callport_list, use_jenerics_alphabet
        
        file.print "{\n"

        print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_callport\n"
        # セル構造体の呼び口フィールドの定義を生成
        gen_rust_cell_structure_callport file, callport_list, use_jenerics_alphabet

        print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_attribute\n"
        # セル構造体の属性フィールドの定義を生成
        gen_rust_cell_structure_attribute file, @celltype

        print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_variable\n"
        # セル構造体の変数フィールドの定義を生成
        gen_rust_cell_structure_variable file, @celltype

        print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_ex_ctrl_ref\n"
        # セル構造体の ex_ctrl_ref フィールドの定義を生成
        gen_rust_cell_structure_ex_ctrl_ref file, @celltype

        file.print "}\n\n"
        
        print "#{@celltype.get_global_name.to_s}: gen_rust_variable_structure\n"
        # 変数構造体の定義を生成
        gen_rust_variable_structure file, @celltype

        print "#{@celltype.get_global_name.to_s}: gen_rust_sync_variable_structure\n"
        # Sync変数構造体の定義を生成
        gen_rust_sync_variable_structure file, @celltype

        print "#{@celltype.get_global_name.to_s}: gen_rust_impl_sync_trait_for_sync_variable_structure\n"
        # Syncトレイトの実装を生成
        gen_rust_impl_sync_trait_for_sync_variable_structure file, @celltype

        print "#{@celltype.get_global_name.to_s}: gen_rust_entry_structure\n"
        # 受け口構造体の定義と初期化を生成
        gen_rust_entry_structure file, @celltype, callport_list

        print "#{@celltype.get_global_name.to_s}: gen_rust_entryport_structure_initialize\n"
        # ロックガード構造体の定義を生成
        gen_rust_lock_guard_structure file, @celltype, callport_list, use_jenerics_alphabet

        print "#{@celltype.get_global_name.to_s}: gen_main_lib_rs\n"
        # main.rs もしくは lib.rs に mod を追加する
        gen_main_lib_rs @celltype

        @celltype.get_cell_list.each{ |cell|

            print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_header_initialize\n"
            # セルの構造体の初期化の先頭部を生成
            gen_rust_cell_structure_header_initialize file, cell

            print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_jenerics_initialize\n"
            # セル構造体の初期化ためのジェネリクス代入部を生成
            gen_rust_cell_structure_jenerics_initialize file, cell, callport_list, use_jenerics_alphabet

            file.print "{\n"

            print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_callport_initialize\n"
            # セルの構造体の呼び口フィールドの初期化を生成
            gen_rust_cell_structure_callport_initialize file, cell, callport_list

            print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_attribute_initialize\n"
            # セルの構造体の属性フィールドの初期化を生成
            gen_rust_cell_structure_attribute_initialize file, @celltype, cell

            print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_variable_initialize\n"
            # セルの構造体の変数フィールドの初期化を生成
            gen_rust_cell_structure_variable_initialize file, @celltype, cell

            print "#{@celltype.get_global_name.to_s}: gen_rust_cell_structure_ex_ctrl_ref_initialize\n"
            # ex_ctrl_ref フィールドの初期化を生成
            gen_rust_cell_structure_ex_ctrl_ref_initialize file, @celltype, cell

            file.print "};\n\n"

            print "#{@celltype.get_global_name.to_s}: gen_rust_variable_structure_initialize\n"
            # 変数構造体の初期化を生成
            gen_rust_variable_structure_initialize file, cell

            print "#{@celltype.get_global_name.to_s}: gen_rust_ex_ctrl_ref_initialize\n"
            # ex_ctrl_ref の初期化を生成
            gen_rust_ex_ctrl_ref_initialize file, cell

            print "#{@celltype.get_global_name.to_s}: gen_rust_entryport_structure_initialize\n"
            # 受け口構造体の初期化を生成
            gen_rust_entryport_structure_initialize file, @celltype, cell

        } # celltype.get_cell_list.each

        print "#{@celltype.get_global_name.to_s}: gen_rust_impl_drop_for_lock_guard_structure\n"
        # ロックガードに Drop トレイトを実装する
        gen_rust_impl_drop_for_lock_guard_structure file, @celltype, callport_list, use_jenerics_alphabet

        if check_only_entryport_celltype @celltype then
        else
            print "#{@celltype.get_global_name.to_s}: gen_rust_get_cell_ref\n"
            # get_cell_ref 関数を生成する
            gen_rust_get_cell_ref file, @celltype, callport_list, use_jenerics_alphabet
        end

        # dyn が必要かどうかを判断する
        # if check_gen_dyn_for_celltype @celltype then
        #     print "#{@celltype.get_global_name.to_s}: gen_impl_sync_send_trait\n"
        #     # Sync と Send トレイトを実装する
        #     gen_impl_sync_send_trait file, @celltype
        # end
        file.close

        @celltype.get_port_list.each{ |port|

            if port.get_port_type == :ENTRY then

                puts "#{@celltype.get_global_name.to_s}: get_diff_between_gen_and_src"
                get_diff_between_gen_and_src "#{snake_case(@celltype.get_global_name.to_s)}_impl.rs", "impl"

                impl_file = CFile.open( "#{$gen}/tecs_impl/#{snake_case(@celltype.get_global_name.to_s)}_impl.rs", "w" )

                print "#{@celltype.get_global_name.to_s}: gen_use_for_impl_file\n"
                # implファイル用のuse文を生成
                gen_use_for_impl_file impl_file, @celltype
                
                print "#{@celltype.get_global_name.to_s}: gen_rust_entryport_function\n"
                # セルタイプに受け口がある場合，impl ファイルを生成する
                gen_rust_entryport_function impl_file, @celltype, callport_list

                impl_file.close

                # 既に Cargo プロジェクトにファイルがある場合、ユーザがコードを実装済みとして、コピーしない
                # つまり、impl ファイルは最適化の際に更新しない
                if File.exist?("#{@@cargo_path}/src/tecs_impl/#{snake_case(@celltype.get_global_name.to_s)}_impl.rs") == false then
                    puts "#{@celltype.get_global_name.to_s}: copy #{snake_case(@celltype.get_global_name.to_s)}_impl.rs to cargo\n"
                    copy_gen_files_to_cargo "#{snake_case(@celltype.get_global_name.to_s)}_impl.rs", "impl"
                end

                break
            end
        }

        # } # celltype.get_cell_list.each

        print "#{@celltype.get_global_name.to_s}: gen_trait_files\n"
        # トレイトファイルを生成する
        # これは，各セルタイプの呼び口につながっているシグニチャに対してのみ，トレイトファイルを生成する
        gen_trait_files @celltype

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


        puts "#{@celltype.get_global_name.to_s}: gen_tecs_struct_def_rs"
        gen_tecs_struct_def_rs
    end # gen_factory

end
