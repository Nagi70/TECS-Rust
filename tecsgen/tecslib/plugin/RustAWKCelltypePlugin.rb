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

require 'set'
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
    @@use_periodic_reactor_gen = false
    @@use_reactor_gen = false
    @@use_sink_reactor_gen = false
    @@reactor_api_list = []
    @@non_default_impl_type_list = ["awkernel_lib::time::Time"] # defaultの実装がない型のリスト(awkernelのTime型など)
    @@dag_reactor_body_celltype_list = []
    @@dag_sink_reactor_body_celltype_list = []
    @@dag_periodic_reactor_body_celltype_list = []
    @@reactor_body_celltype_list = []
    @@sink_reactor_body_celltype_list = []
    @@periodic_reactor_body_celltype_list = []

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

      plugin_option = @plugin_arg_str.split(",").map(&:strip)

      if plugin_option.include?("DAG_REACTOR_BODY") then
        @@dag_reactor_body_celltype_list.push(@celltype)
        gen_dag_reactor_celltype(@celltype)
      elsif plugin_option.include?("REACTOR_BODY") then
        @@reactor_body_celltype_list.push(@celltype)
        gen_dag_reactor_celltype(@celltype, false)
      elsif plugin_option.include?("DAG_SINK_REACTOR_BODY") then
        @@dag_sink_reactor_body_celltype_list.push(@celltype)
        gen_dag_sink_reactor_celltype(@celltype)
      elsif plugin_option.include?("SINK_REACTOR_BODY") then
        @@sink_reactor_body_celltype_list.push(@celltype)
        gen_dag_sink_reactor_celltype(@celltype, false)
      elsif plugin_option.include?("DAG_PERIODIC_REACTOR_BODY") then
        @@dag_periodic_reactor_body_celltype_list.push(@celltype)
        gen_dag_periodic_reactor_celltype(@celltype)
      elsif plugin_option.include?("PERIODIC_REACTOR_BODY") then
        @@periodic_reactor_body_celltype_list.push(@celltype)
        gen_dag_periodic_reactor_celltype(@celltype, false)
      end
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
      file.print "/* '#{self.class.name}' post code */\n"

      @@dag_reactor_body_celltype_list.each do |celltype|
        gen_dag_reactor_post_code(file, celltype)
      end

      @@reactor_body_celltype_list.each do |celltype|
        gen_dag_reactor_post_code(file, celltype, false)
      end

      @@dag_sink_reactor_body_celltype_list.each do |celltype|
        gen_dag_sink_reactor_post_code(file, celltype)
      end

      @@sink_reactor_body_celltype_list.each do |celltype|
        gen_dag_sink_reactor_post_code(file, celltype, false)
      end

      @@dag_periodic_reactor_body_celltype_list.each do |celltype|
        gen_dag_periodic_reactor_post_code(file, celltype)
      end

      @@periodic_reactor_body_celltype_list.each do |celltype|
        gen_dag_periodic_reactor_post_code(file, celltype, false)
      end

    end

    def gen_dag_reactor_celltype celltype, in_dag=true

        option = "DAG_REACTOR"
        file_suffix = "dag_reactor"
        suffix = "DagReactor"
        if !in_dag then
            option = "REACTOR"
            file_suffix = "reactor"
            suffix = "Reactor"
        end

        file = CFile.open( "#{$gen}/#{celltype.get_global_name}_#{file_suffix}.cdl", "w" )

        e_reactor = get_awkernel_callback_entryport_for_celltype(celltype)

        # 指定する属性が定義されているかを確認する
        # 定義されていても omit が指定されていない場合はエラーにする
        reactor_name = get_reactor_attribute(celltype, :reactorName)
        subscribe_topic_names = get_reactor_attribute(celltype, :subscribeTopicNames)
        publish_topic_names = get_reactor_attribute(celltype, :publishTopicNames)
        sched_type = get_reactor_attribute(celltype, :schedType)
        
        # key: トピック名, value: トピックの型
        publish_topic_type_hash = get_topic_type_hash_from_attr(publish_topic_names)
        subscribe_topic_type_hash = get_topic_type_hash_from_attr(subscribe_topic_names)

        # トピック用の口があるかを確認する
        check_topic_port_exist(celltype, publish_topic_type_hash, :CALL)
        check_topic_port_exist(celltype, subscribe_topic_type_hash, :ENTRY)

        cb_sig = e_reactor.get_signature
        publish_topic_arg, subscribe_topic_arg = get_topic_list_from_callback_signature(cb_sig)

        # Pub/Sub 用の口の定義とコールバックシグニチャの定義の整合性を確認する
        # 現在は、属性で定義されたトピック名の順序とコールバックシグニチャの引数の順序が同じであることを想定している
        check_topic_type_diff(celltype, cb_sig, publish_topic_type_hash, publish_topic_arg)
        check_topic_type_diff(celltype, cb_sig, subscribe_topic_type_hash, subscribe_topic_arg)

        file.print <<~CDL
          [active, generate(RustAWKPlugin, "#{option}")]
          celltype #{celltype.get_global_name}#{suffix} {
            [async] call #{cb_sig.get_global_name} c#{suffix};
            attr {
              [omit] PLType("Cow") name = PL_EXP("#{reactor_name.get_initializer}");
              [omit] PLType("SchedulerType") schedType = PL_EXP("#{sched_type.get_initializer}");
              [omit] PLType("Cow") publishTopicNames = PL_EXP("#{publish_topic_names.get_initializer}");
              [omit] PLType("Cow") subscribeTopicNames = PL_EXP("#{subscribe_topic_names.get_initializer}");
            };
          };

        CDL

        file.close
    end

    def self.gen_dag_reactor_post_code file, celltype, in_dag=true
        
        # パブリッシュ用呼び口が、正しいサブスクライバ受け口に結合されているかを確認する
        validate_publisher_topics_in_subscriber(celltype)

        file_suffix = "dag_reactor"
        suffix = "DagReactor"
        if !in_dag then
            file_suffix = "reactor"
            suffix = "Reactor"
        end

        file.print "import(\"#{$gen}/#{celltype.get_global_name}_#{file_suffix}.cdl\");\n\n"

        # cell定義の生成
        celltype.get_cell_list.each do |cell|
            file.print <<~CDL
              cell #{celltype.get_global_name}#{suffix} #{cell.get_global_name}#{suffix} {
                c#{suffix} = #{cell.get_global_name}.eReactor;
              };

            CDL
        end
    end

    def gen_dag_sink_reactor_celltype celltype, in_dag=true

        option = "DAG_SINK_REACTOR"
        file_suffix = "dag_sink_reactor"
        suffix = "DagSinkReactor"
        if !in_dag then
            option = "SINK_REACTOR"
            file_suffix = "sink_reactor"
            suffix = "SinkReactor"
        end

        file = CFile.open( "#{$gen}/#{celltype.get_global_name}_#{file_suffix}.cdl", "w" )

        e_reactor = get_awkernel_callback_entryport_for_celltype(celltype)

        # 指定する属性が定義されているかを確認する
        reactor_name = get_reactor_attribute(celltype, :reactorName)
        subscribe_topic_names = get_reactor_attribute(celltype, :subscribeTopicNames)
        sched_type = get_reactor_attribute(celltype, :schedType)
        relative_deadline = get_reactor_attribute(celltype, :relativeDeadline)

        # パブリッシュトピック属性が定義されていないことを確認し、定義されていた場合エラー
        publish_topic_names = celltype.get_attribute_list.find { |a| a.get_name == :publishTopicNames}
        if !publish_topic_names == nil then
            puts "error: #{celltype.get_global_name} has defined publishTopicNames. Don't define it."
            exit(1)
        end
        
        # key: トピック名, value: トピックの型
        subscribe_topic_type_hash = get_topic_type_hash_from_attr(subscribe_topic_names)

        # トピック用の口があるかを確認する
        check_topic_port_exist(celltype, subscribe_topic_type_hash, :ENTRY)

        cb_sig = e_reactor.get_signature
        publish_topic_arg, subscribe_topic_arg = get_topic_list_from_callback_signature(cb_sig)

        if publish_topic_arg.any? then
            puts "error: The function in #{cb_sig.get_global_name} has [out] arguments. Don't define it."
            exit(1)
        end

        # Sub 用の口の定義とコールバックシグニチャの定義の整合性を確認する
        # 現在は、属性で定義されたトピック名の順序とコールバックシグニチャの引数の順序が同じであることを想定している
        check_topic_type_diff(celltype, cb_sig, subscribe_topic_type_hash, subscribe_topic_arg)

        file.print <<~CDL
        [active, generate(RustAWKPlugin, "#{option}")]
        celltype #{celltype.get_global_name}#{suffix} {
          [async] call #{cb_sig.get_global_name} c#{suffix};
          attr {
            [omit] PLType("Cow") name = PL_EXP("#{reactor_name.get_initializer}");
            [omit] PLType("SchedulerType") schedType = PL_EXP("#{sched_type.get_initializer}");
            [omit] PLType("Cow") subscribeTopicNames = PL_EXP("#{subscribe_topic_names.get_initializer}");
            [omit] PLType("Cow") relativeDeadline = PL_EXP("#{relative_deadline.get_initializer}");
          };
        };
      
      CDL

      file.close
    end

    def self.gen_dag_sink_reactor_post_code file, celltype, in_dag=true

        file_suffix = "dag_sink_reactor"
        suffix = "DagSinkReactor"
        if !in_dag then
            file_suffix = "sink_reactor"
            suffix = "SinkReactor"
        end

        file.print "import(\"#{$gen}/#{celltype.get_global_name}_#{file_suffix}.cdl\");\n\n"

        celltype.get_cell_list.each do |cell|
            file.print <<~CDL
              cell #{celltype.get_global_name}#{suffix} #{cell.get_global_name}#{suffix} {
                c#{suffix} = #{cell.get_global_name}.eReactor;
              };

            CDL
        end
    end

    def gen_dag_periodic_reactor_celltype celltype, in_dag=true
        
        option = "DAG_PERIODIC_REACTOR"
        file_suffix = "dag_periodic_reactor"
        suffix = "DagPeriodicReactor"
        if !in_dag then
            option = "PERIODIC_REACTOR"
            file_suffix = "periodic_reactor"
            suffix = "PeriodicReactor"
        end

        file = CFile.open( "#{$gen}/#{celltype.get_global_name}_#{file_suffix}.cdl", "w" )

        e_reactor = get_awkernel_callback_entryport_for_celltype(celltype)

        # 指定する属性が定義されているかを確認する
        reactor_name = get_reactor_attribute(celltype, :reactorName)
        publish_topic_names = get_reactor_attribute(celltype, :publishTopicNames)
        sched_type = get_reactor_attribute(celltype, :schedType)
        period = get_reactor_attribute(celltype, :period)

        # サブスクライブトピック属性が定義されていないことを確認し、定義されていた場合エラー
        subscribe_topic_names = celltype.get_attribute_list.find { |a| a.get_name == :subscribeTopicNames}
        if !subscribe_topic_names == nil then
            puts "error: #{celltype.get_global_name} has defined subscribeTopicNames. Don't define it."
            exit(1)
        end
        
        # key: トピック名, value: トピックの型
        publish_topic_type_hash = get_topic_type_hash_from_attr(publish_topic_names)

        # トピック用の口があるかを確認する
        check_topic_port_exist(celltype, publish_topic_type_hash, :CALL)

        cb_sig = e_reactor.get_signature
        publish_topic_arg, subscribe_topic_arg = get_topic_list_from_callback_signature(cb_sig)

        if subscribe_topic_arg.any? then
            puts "error: The function in #{cb_sig.get_global_name} has [in] arguments. Don't define it."
            exit(1)
        end

        # Pub 用の口の定義とコールバックシグニチャの定義の整合性を確認する
        # 現在は、属性で定義されたトピック名の順序とコールバックシグニチャの引数の順序が同じであることを想定している
        check_topic_type_diff(celltype, cb_sig, publish_topic_type_hash, publish_topic_arg)

        file.print <<~CDL
          [active, generate(RustAWKPlugin, "#{option}")]
          celltype #{celltype.get_global_name}#{suffix} {
            [async] call #{cb_sig.get_global_name} c#{suffix};
            attr {
              [omit] PLType("Cow") name = PL_EXP("#{reactor_name.get_initializer}");
              [omit] PLType("SchedulerType") schedType = PL_EXP("#{sched_type.get_initializer}");
              [omit] PLType("Cow") publishTopicNames = PL_EXP("#{publish_topic_names.get_initializer}");
              [omit] PLType("Cow") period = PL_EXP("#{period.get_initializer}");
            };
          };

        CDL

        file.close
    end

    def self.gen_dag_periodic_reactor_post_code file, celltype, in_dag=true

        # パブリッシュ用呼び口が、正しいサブスクライバ受け口に結合されているかを確認する
        validate_publisher_topics_in_subscriber(celltype)

        file_suffix = "dag_periodic_reactor"
        suffix = "DagPeriodicReactor"
        if !in_dag then
            file_suffix = "periodic_reactor"
            suffix = "PeriodicReactor"
        end

        file.print "import(\"#{$gen}/#{celltype.get_global_name}_#{file_suffix}.cdl\");\n\n"

        celltype.get_cell_list.each do |cell|
            file.print <<~CDL
              cell #{celltype.get_global_name}#{suffix} #{cell.get_global_name}#{suffix} {
                c#{suffix} = #{cell.get_global_name}.eReactor;
              };

            CDL
        end
    end

    def self.validate_publisher_topics_in_subscriber celltype

        publish_topic_names = celltype.get_attribute_list.find { |a| a.get_name == :publishTopicNames }
        publish_topic_name_list = publish_topic_names.get_initializer.to_s.split(",").map(&:strip)

        celltype.get_cell_list.each do |cell|
            publish_topic_name_list.each do |p_topic|
            c_publish = "c#{p_topic}"
               # TODO: get_rhs_cell2 の使い方があっているか分からない
            join = cell.get_join_list.get_item(c_publish.to_sym)
            # 呼び口が配列の場合、インデックス指定がない場合はエラーにする
            # 1対多のPub/Sub関係を表現するために、呼び口が配列かどうかを確認する
            case join.get_subscript
            when nil    ## 呼び口が配列ではない場合
                subscribe_cell = join.get_rhs_cell2
                subscribe_topic_names = subscribe_cell.get_celltype.get_attribute_list.find { |a| a.get_name == :subscribeTopicNames }
                subscribe_topic_name_list = subscribe_topic_names.get_initializer.to_s.split(",").map(&:strip)
                
                unless subscribe_topic_name_list.include?(p_topic)
                    puts "error: #{p_topic} that #{cell.get_global_name.to_s} publish does not be included in subscribeTopicNames in #{subscribe_cell.get_global_name.to_s}"
                    exit 1
                end
            when -1     ## 呼び口が配列で、インデックス指定がない場合
                puts "error: #{cell.get_global_name.to_s}'s #{c_publish} is array. Please specify index."
                exit 1
            else        ## 呼び口が配列で、インデックス指定がある場合
                join.get_array_member2.each do |j|
                    subscribe_cell = j.get_rhs_cell2
                    subscribe_topic_names = subscribe_cell.get_celltype.get_attribute_list.find { |a| a.get_name == :subscribeTopicNames }
                    subscribe_topic_name_list = subscribe_topic_names.get_initializer.to_s.split(",").map(&:strip)
                    
                    unless subscribe_topic_name_list.include?(p_topic)
                        puts "error: #{p_topic} that #{cell.get_global_name.to_s} publish does not be included in subscribeTopicNames in #{subscribe_cell.get_global_name.to_s}"
                        exit 1
                    end
                end
            end
          end
        end
    end

    # topic属性の初期値と同じ順番でキーを作成したハッシュを取得する
    def get_topic_type_hash_from_attr attr
        initializer = attr.get_initializer.to_s.split(",").map(&:strip)
        topic_type_hash = {}
        initializer.each do |topic_name|
            topic_type_hash[topic_name] = nil
        end
        return topic_type_hash
    end

    def check_topic_port_exist(celltype, topic_hash, port_type)
        remaining = Set.new(topic_hash.keys)
        
        # Pub/Sub 用の口が定義されているかを確認する
        celltype.get_port_list.each do |port|
          next unless port.get_port_type == port_type
          
          # トピック用の口が定義されているかを確認する (呼び口名は "c+トピック名"、受け口名は "e+トピック名"を想定している)
          topic_name = port.get_name.to_s.slice(1..-1)
          next unless topic_hash.key?(topic_name)
          
          # omit が指定されていない場合はエラーにする
          if port_type == :CALL && !port.is_omit?
            puts "error: #{port.get_global_name.to_s} is not omit. Please specify [omit]."
            exit(1)
          end
          
          # トピックの型を取得し、ハッシュに追加する
          topic_hash[topic_name] = get_topic_type(port)
           # 適切にパブリッシュ用呼び口が定義されていた場合は、remaining から削除する
          remaining.delete(topic_name)
        end
        
        # 不足チェック
        # remaining にトピックが残っている場合、トピック用の口の定義が不足しているためエラーにする
        unless remaining.empty?
          remaining.each do |topic_name|
            port_label = port_type == :CALL ? "call port that publish topic" : "entry port that subscribe topic"
            prefix = port_type == :CALL ? "c" : "e"
            puts "error: #{celltype.get_global_name.to_s} has not defined #{port_label} #{topic_name}. Please define #{prefix}#{topic_name} with [omit]."
            exit 1
          end
        end
    end

    def check_topic_type_diff celltype, callback_signature, attr_topic_hash, arg_topic_hash
        v1 = attr_topic_hash.values
        v2 = arg_topic_hash.values

        if v1.length != v2.length
            puts "error: length of topicTypeNames in #{celltype.get_global_name.to_s} and length of argments in #{callback_signature.get_global_name.to_s} mismatch"
            exit 1
        end

        (0...v1.length).each do |i|
            unless v1[i] == v2[i]
                puts "error: The type of the #{i + 1}-th topic in #{celltype.get_global_name.to_s}'s topicTypeNames does not match the type of the #{i + 1}-th argument in #{callback_signature.get_global_name.to_s}. Please define the topics in topicTypeNames and the arguments in #{callback_signature.get_global_name.to_s} in the same order."
                exit 1
            end
        end
    end

    # リアクター生成のために、指定されたシンボルの属性が定義されているかをチェックする
    # もし定義されていなかった場合はエラー、[omit]になっていなかった場合もエラー
    def get_reactor_attribute celltype, sym
        attr = celltype.get_attribute_list.find { |a| a.get_name == sym}
        if attr == nil then
            puts "error: #{celltype.get_global_name} has not defined #{sym.to_s}. Please define it with [omit] and initialize it with PL_EXP()."
            exit(1)
        end
        if !attr.is_omit? then
            puts "error: #{attr.get_global_name} is not omit. Please specify [omit]."
            exit(1)
        end
        return attr
    end

    # セルタイプに eReactor という名前の受け口があるかどうかを確認する
    # TODO: 現在は eReactor という名前のみを想定している
    def get_awkernel_callback_entryport_for_celltype celltype
        celltype.get_port_list.each do |port|
            if port.get_port_type == :ENTRY && port.get_name.to_s == "eReactor" then
                return port
            end
        end

        puts "error: Can't find eReactor in #{celltype.get_global_name.to_s}, please define it."
        exit 1
        return nil
    end

    def get_topic_type port
        signature = port.get_signature
        func_array = signature.get_function_head_array
        if func_array.length == 0 then
          puts "error: #{signature.get_global_name.to_s} has no function head"
          exit 1
        elsif func_array.length > 1 then
          puts "warning: #{signature.get_global_name.to_s} has multiple function heads. Use the first one this time."
        end
  
        first_func = func_array.first
        param_list = first_func.get_paramlist
        if param_list.get_items.length == 0 then
          puts "error: #{signature.get_global_name.to_s} has no argument. Please define a topic argument in the signature."
          exit 1
        elsif param_list.get_items.length > 1 then
          puts "warning: #{signature.get_global_name.to_s} has multiple arguments. Use the first one this time."
        end
  
        first_param = param_list.get_items.first
        return c_type_to_rust_type(first_param.get_type)
    end

    def get_topic_list_from_callback_signature signature

        # パブリッシュするトピックとサブスクライブするトピックを取得する
        publish_topic_hash = {}
        subscribe_topic_hash = {}

        # シグニチャの関数が複数ある場合はワーニング
        if signature.get_function_head_array.length == 0 then
            puts "error: #{signature.get_global_name.to_s} has no function head. Please define function with Pub/Sub topic arguments"
            exit 1
        elsif signature.get_function_head_array.length > 1 then
            puts "warning: #{signature.get_global_name.to_s} has multiple function heads. Use the first one this time."
            exit 1
        end

        # コールバックシグニチャの関数の引数のリストを取得
        signature.get_function_head_array.each do |func_head|
            func_head.get_paramlist.get_items.each do |param|
                case param.get_direction
                when :IN
                    subscribe_topic_hash[param.get_name.to_s] = c_type_to_rust_type(param.get_type)
                when :OUT
                    publish_topic_hash[param.get_name.to_s] = c_type_to_rust_type(param.get_type)
                end
            end
        end

        return publish_topic_hash, subscribe_topic_hash
    end

    # オプションから、リアクターの種類を取得する
    def get_reactor_type
        plugin_option = @plugin_arg_str.split(",").map(&:strip)
        if plugin_option.include?("DAG_REACTOR") then
            return "DagReactor"
        elsif plugin_option.include?("DAG_SINK_REACTOR") then
            return "DagSinkReactor"
        elsif plugin_option.include?("DAG_PERIODIC_REACTOR") then
            return "DagPeriodicReactor"
        elsif plugin_option.include?("PERIODIC_REACTOR") then
            return "PeriodicReactor"
        elsif plugin_option.include?("REACTOR") then
            return "Reactor"
        elsif plugin_option.include?("SINK_REACTOR") then
            return "SinkReactor"
        else
            return "unknown"
        end
    end

    # no_std や feature などのコンパイルオプションを生成する
    def gen_compile_option_in_main_lib_rs file, celltype
        file.print "#![no_std]\n"
    end

    def gen_entryport_function_in_main_lib_rs file, celltype

        case get_reactor_type
        when "DagReactor"
            add_dag_reactor_api file, celltype
        when "Reactor"
            add_dag_reactor_api file, celltype, false
        when "DagSinkReactor"
            add_dag_sink_reactor_api file, celltype
        when "SinkReactor"
            add_dag_sink_reactor_api file, celltype, false
        when "DagPeriodicReactor"
            add_dag_periodic_reactor_api file, celltype
        when "PeriodicReactor"
            add_dag_periodic_reactor_api file, celltype, false
        end

        return if @@use_periodic_reactor_gen == false && 
                  @@use_reactor_gen == false && 
                  @@use_sink_reactor_gen == false

        file.print "extern crate alloc;\n"
        file.print "use alloc::{borrow::Cow, vec};\n"
        file.print "use awkernel_async_lib::dag::{create_dag, finish_create_dags};\n"
        file.print "use awkernel_async_lib::scheduler::SchedulerType;\n"
        # TODO: delay の時間単位をユーザの指定に応じて変更する
        file.print "use awkernel_lib::delay::wait_microsec;\n"
        file.print "use core::time::Duration;\n\n"

        file.print "use tecs_global::*;\n\n"

        if @@use_periodic_reactor_gen then
            # file.print "use tecs_celltype::t_dag_periodic_reactor::*;\n"
            # file.print "use tecs_signature::s_periodic_reactorbody::*;\n\n"
        end
        if @@use_reactor_gen then
            # file.print "use tecs_celltype::t_dag_reactor::*;\n"
            # file.print "use tecs_signature::s_reactorbody::*;\n\n"
        end
        if @@use_sink_reactor_gen then
            # file.print "use tecs_celltype::t_dag_sink_reactor::*;\n"
            # file.print "use tecs_signature::s_sink_reactorbody::*;\n\n"
        end

        # file.print "use tecs_signature::s_reactorbody::*;\n\n"

        file.print "pub async fn run() {\n\n"
        file.print "\twait_microsec(1000000);\n\n"
        file.print "\tlet dag = create_dag();\n\n"

        @@reactor_api_list.each do |reactor_api|
            file.print reactor_api
            file.print "\n\n"
        end

        file.print "\tlet _ = finish_create_dags(&[dag.clone()]).await;\n"
        file.print "}\n"
    end

    def add_dag_periodic_reactor_api file, celltype, in_dag=true
        @@use_periodic_reactor_gen = true

        suffix = "DagPeriodicReactor"
        api = "dag.register_periodic_reactor"
        if !in_dag then
            suffix = "PeriodicReactor"
            api = "spawn_periodic_reactor"
        end

        celltype.get_cell_list.each do |cell|

            # 生成されるリアクターセルタイプの呼び口を取得する
            c_dag_periodic_reactor = celltype.get_port_list.find { |p| p.get_port_type == :CALL && p.get_name.to_s == "c#{suffix}" }

            publish_topic_hash, subscribe_topic_hash = get_topic_list_from_callback_signature(c_dag_periodic_reactor.get_signature)
            
            reactor_api = "\tuse tecs_signature::#{snake_case(c_dag_periodic_reactor.get_signature.get_global_name.to_s)}::*;\n\n"

            # TODO: プラグインのオプションから、返り値の型を特定する
            reactor_api += "\t#{api}::<_, ("
            publish_topic_hash.values.each do |topic_type|
                reactor_api += "#{topic_type},"
            end
            reactor_api += ")>(\n"

            reactor_api += "\t\t\"#{cell.get_attr_initializer("name".to_sym).to_s}\".into(),\n"
            
            # TODO: プラグインのオプションから、返り値の型を特定する
            reactor_api += "\t\t|| -> ("
            publish_topic_hash.values.each do |topic_type|
                reactor_api += "#{topic_type},"
            end
            reactor_api += ") {\n"

            # TODO: 型に応じて適切な初期化をする必要がある
            # TODO: オリジナルの型に対応させるのは難しいかもしれない
            publish_topic_hash.each do |topic_arg_name, (topic_type)|
                reactor_api += "\t\t\tlet mut #{topic_arg_name}: #{topic_type} = Default::default();\n"
            end

            reactor_api += "\t\t\ttecs_celltype::#{snake_case(celltype.get_global_name.to_s)}::#{cell.get_global_name.to_s.upcase}.#{snake_case(c_dag_periodic_reactor.get_name.to_s)}.#{c_dag_periodic_reactor.get_signature.get_function_head_array.first.get_name}("
            c_dag_periodic_reactor.get_signature.get_function_head_array.each do |func_head|
                func_head.get_paramlist.get_items.each do |param|
                    case param.get_direction
                    when :OUT
                        reactor_api += "&mut #{param.get_name.to_s}"
                    end
                    reactor_api += ", " unless param == func_head.get_paramlist.get_items.last
                end
                break
            end
            reactor_api += ");\n"

            reactor_api += "\t\t\t("
            publish_topic_hash.keys.each do |topic_arg_name|
                reactor_api += "#{topic_arg_name},"
            end
            reactor_api += ")\n"

            reactor_api += "\t\t},\n"

            reactor_api += "\t\tvec![Cow::from(\"#{cell.get_attr_initializer("publishTopicNames".to_sym).to_s}\")],\n"

            # TODO: sched_type 属性の初期値を明確にする必要がある。現在は、スケジューラ名 (FIFOなど)のみを想定している
            reactor_api += "\t\t#{cell.get_attr_initializer("schedType".to_sym).to_s},\n"
            # TODO: period 属性の初期値を明確にする必要がある。現在は、関数を含めた形 (Duration::from_secs(1) など) のみを想定している
            reactor_api += "\t\t#{cell.get_attr_initializer("period".to_sym).to_s},\n"
            reactor_api += "\t)\n"
            reactor_api += "\t.await;"

            @@reactor_api_list << reactor_api
        end

        @@reactor_api_list.uniq!
    end

    def add_dag_reactor_api file, celltype, in_dag=true
        @@use_reactor_gen = true

        suffix = "DagReactor"
        api = "dag.register_reactor"
        if !in_dag then
            suffix = "Reactor"
            api = "spawn_reactor"
        end

        celltype.get_cell_list.each do |cell|

            # 生成されるリアクターセルタイプの呼び口を取得する
            c_dag_reactor = celltype.get_port_list.find { |p| p.get_port_type == :CALL && p.get_name.to_s == "c#{suffix}" }

            publish_topic_hash, subscribe_topic_hash = get_topic_list_from_callback_signature(c_dag_reactor.get_signature)

            reactor_api = "\tuse tecs_signature::#{snake_case(c_dag_reactor.get_signature.get_global_name.to_s)}::*;\n\n"

            # TODO: プラグインのオプションから、返り値の型を特定する
            reactor_api += "\t#{api}::<_, ("
            subscribe_topic_hash.values.each do |topic_type|
                reactor_api += "#{topic_type},"
            end
            reactor_api += "), ("
            publish_topic_hash.values.each do |topic_type|
                reactor_api += "#{topic_type},"
            end
            reactor_api += ")>(\n"

            # reactor_name 引数を生成する
            reactor_api += "\t\t\"#{cell.get_attr_initializer("name".to_sym).to_s}\".into(),\n"
            
            # f 引数を生成する
            # TODO: プラグインのオプションから、返り値の型を特定する
            reactor_api += "\t\t|("
            subscribe_topic_hash.keys.each do |topic_arg_name|
                reactor_api += "#{topic_arg_name},"
            end
            reactor_api += "): "
            reactor_api += "("
            subscribe_topic_hash.values.each do |topic_type|
                reactor_api += "#{topic_type},"
            end
            reactor_api += ")"
            reactor_api += "| -> ("
            publish_topic_hash.values.each do |topic_type|
                reactor_api += "#{topic_type},"
            end
            reactor_api += ") {\n"

            # TODO: 型に応じて適切な初期化をする必要がある
            # TODO: オリジナルの型に対応させるのは難しいかもしれない
            publish_topic_hash.each do |topic_arg_name, (topic_type)|
                reactor_api += "\t\t\tlet mut #{topic_arg_name}: #{topic_type} = Default::default();\n"
            end

            reactor_api += "\t\t\ttecs_celltype::#{snake_case(celltype.get_global_name.to_s)}::#{cell.get_global_name.to_s.upcase}.#{snake_case(c_dag_reactor.get_name.to_s)}.#{c_dag_reactor.get_signature.get_function_head_array.first.get_name}("
            c_dag_reactor.get_signature.get_function_head_array.each do |func_head|
                func_head.get_paramlist.get_items.each do |param|
                    case param.get_direction
                    when :IN
                        reactor_api += "&#{param.get_name.to_s}"
                    when :OUT
                        reactor_api += "&mut #{param.get_name.to_s}"
                    end
                    reactor_api += ", " unless param == func_head.get_paramlist.get_items.last
                end
                break
            end
            reactor_api += ");\n"

            reactor_api += "\t\t\t("
            publish_topic_hash.keys.each do |topic_arg_name|
                reactor_api += "#{topic_arg_name},"
            end
            reactor_api += ")\n"

            reactor_api += "\t\t},\n"

            # subscribeTopicNames 引数を生成する
            reactor_api += "\t\tvec![Cow::from(\"#{cell.get_attr_initializer("subscribeTopicNames".to_sym).to_s}\")],\n"

            # publishTopicNames 引数を生成する
            reactor_api += "\t\tvec![Cow::from(\"#{cell.get_attr_initializer("publishTopicNames".to_sym).to_s}\")],\n"

            # TODO: sched_type 属性の初期値を明確にする必要がある。現在は、スケジューラ名 (FIFOなど)のみを想定している
            reactor_api += "\t\t#{cell.get_attr_initializer("schedType".to_sym).to_s},\n"
            reactor_api += "\t)\n"
            reactor_api += "\t.await;"

            @@reactor_api_list << reactor_api
        end

        @@reactor_api_list.uniq!
    end

    def add_dag_sink_reactor_api file, celltype, in_dag=true
        @@use_sink_reactor_gen = true

        suffix = "DagSinkReactor"
        api = "dag.register_sink_reactor"
        if !in_dag then
            suffix = "SinkReactor"
            api = "spawn_sink_reactor"
        end

        celltype.get_cell_list.each do |cell|

            # 生成されるリアクターセルタイプの呼び口を取得する
            c_dag_sink_reactor = celltype.get_port_list.find { |p| p.get_port_type == :CALL && p.get_name.to_s == "c#{suffix}" }

            publish_topic_hash, subscribe_topic_hash = get_topic_list_from_callback_signature(c_dag_sink_reactor.get_signature)

            reactor_api = "\tuse tecs_signature::#{snake_case(c_dag_sink_reactor.get_signature.get_global_name.to_s)}::*;\n\n"

            # TODO: プラグインのオプションから、返り値の型を特定する
            reactor_api += "\t#{api}::<_, ("
            subscribe_topic_hash.values.each do |topic_type|
                reactor_api += "#{topic_type},"
            end
            reactor_api += ")>(\n"

            # reactor_name 引数を生成する
            reactor_api += "\t\t\"#{cell.get_attr_initializer("name".to_sym).to_s}\".into(),\n"
            
            # f 引数を生成する
            # TODO: プラグインのオプションから、返り値の型を特定する
            reactor_api += "\t\t|("
            subscribe_topic_hash.keys.each do |topic_arg_name|
                reactor_api += "#{topic_arg_name},"
            end
            reactor_api += "): "
            reactor_api += "("
            subscribe_topic_hash.values.each do |topic_type|
                reactor_api += "#{topic_type},"
            end
            reactor_api += ")| {\n"

            reactor_api += "\t\t\ttecs_celltype::#{snake_case(celltype.get_global_name.to_s)}::#{cell.get_global_name.to_s.upcase}.#{snake_case(c_dag_sink_reactor.get_name.to_s)}.#{c_dag_sink_reactor.get_signature.get_function_head_array.first.get_name}("
            c_dag_sink_reactor.get_signature.get_function_head_array.each do |func_head|
                func_head.get_paramlist.get_items.each do |param|
                    case param.get_direction
                    when :IN
                        reactor_api += "&#{param.get_name.to_s}"
                    end
                    reactor_api += ", " unless param == func_head.get_paramlist.get_items.last
                end
                break
            end
            reactor_api += ");\n"

            reactor_api += "\t\t},\n"

            # subscribeTopicNames 引数を生成する
            reactor_api += "\t\tvec![Cow::from(\"#{cell.get_attr_initializer("subscribeTopicNames".to_sym).to_s}\")],\n"

            # TODO: sched_type 属性の初期値を明確にする必要がある。現在は、スケジューラ名 (FIFOなど)のみを想定している
            reactor_api += "\t\t#{cell.get_attr_initializer("schedType".to_sym).to_s},\n"
            reactor_api += "\t\t#{cell.get_attr_initializer("relativeDeadline".to_sym).to_s},\n"
            reactor_api += "\t)\n"
            reactor_api += "\t.await;"

            @@reactor_api_list << reactor_api
        end

        @@reactor_api_list.uniq!
    end

    #----------------------------------------
    # 指定セルを起点に [async] 呼び口を探索する
    # アルゴリズム:
    # 1. セルの全呼び口を調査し [async] があれば即返す
    # 2. 見つからない場合は最初の呼び口に接続されているセルを再帰的に探索
    # （幅優先探索に近いが，手順はユーザ指定に従い最初の呼び口のみ深掘り）
    # 戻り値: [見つかったセル, 呼び口] もしくは nil
    #----------------------------------------
    def find_async_callport(cell, visited = {})
        return nil if cell.nil? || visited[cell]
        visited[cell] = true

        callports = cell.get_celltype.get_port_list.select { |p| p.get_port_type == :CALL }

        async_port = callports.find { |p| p.is_async? }
        return [cell, async_port] if async_port

        first_port = callports.first
        return nil unless first_port

        join = cell.get_join_list.get_item(first_port.get_name.to_s)
        return nil unless join
    
        next_cell = join.get_rhs_cell2
        find_async_callport(next_cell, visited)
    end

    # async 呼び口につながれているシグニチャの関数の引数名を取得する
    # 戻り値: 引数名 -> [型、トピック名] のハッシュ
    # TODO: トピック名は、シグニチャプラグインのオプションで指定されたものを使用する
    def get_topic_list async_callport

        return nil if async_callport.is_async? == false

        # パブリッシュするトピックとサブスクライブするトピックを取得する
        publish_topic_hash = {}
        subscribe_topic_hash = {}

        # シグニチャの関数が複数ある場合はエラー
        if async_callport.get_signature.get_function_head_array.length > 1 then
            puts "error: #{async_callport.get_signature.get_global_name.to_s} has multiple functions, connected by async callport #{async_callport.get_global_name.to_s}"
            exit 1
        end

        # async 呼び口につながれているシグニチャの関数の引数名を取得する
        async_callport.get_signature.get_function_head_array.each do |func_head|
            func_head.get_paramlist.get_items.each do |param|
                case param.get_direction
                when :IN
                    subscribe_topic_hash[param.get_name.to_s] = [ c_type_to_rust_type(param.get_type), nil]
                when :OUT
                    publish_topic_hash[param.get_name.to_s] = [ c_type_to_rust_type(param.get_type), nil]
                end
            end
        end

        return publish_topic_hash, subscribe_topic_hash
    end

    # main.rs もしくは lib.rs に mod 記述を生成する
    def gen_mod_in_main_lib_rs file, celltype
        super(file, celltype)
        file.print "mod tecs_variable;\n"
    end

    # セルタイプが変数を持つ場合、呼び出される
    def gen_use_mutex file

        # TODO: 将来的に排他制御の選択肢を増やす可能性がある
        case check_gen_mutex_or_not_for_celltype @celltype
        when "mutex"
            file.print "use awkernel_lib::sync::mutex::{MCSNode, Mutex, LockGuard};\n"
        when "mix"
            file.print "use awkernel_lib::sync::mutex::{MCSNode, Mutex, LockGuard};\n"
            # file.print "use core::cell::UnsafeCell;\n"
        when "none"
            # file.print "use core::cell::UnsafeCell;\n"
        end

        file.print "use crate::tecs_variable::*;\n"
        # file.print "use core::cell::UnsafeCell;\n"

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
            # async 指定子がある場合は、pub を付与する
            # リアクターAPIのコールバック関数で、各ルーチンの呼び口を呼び出す生成をするため、pub が必要になる
            if callport.is_async? then
                file.print "\tpub #{snake_case(callport.get_name.to_s)}: &'static "
            else
                file.print "\t#{snake_case(callport.get_name.to_s)}: &'static "
            end

            if check_gen_dyn_for_port(callport) == nil then
                file.print "#{alphabet},\n"
            else
                file.print "(#{check_gen_dyn_for_port(callport)} + Sync + Send),\n"
            end
        end
    end

    def check_async_callport_in_celltype celltype
        celltype.get_port_list.each{ |port|
            if port.get_port_type == :CALL && port.is_async? then
                return true
            end
        }
        return false
    end

    # セルの構造体の初期化の先頭部を生成
    # rodata セクション指定を削除
    def gen_rust_cell_structure_header_initialize file, cell
        # セルタイプに async 呼び口がある場合は、pub を付与する
        # lib.rsから関数を呼び出すため
        if check_async_callport_in_celltype(cell.get_celltype) then
            file.print "pub "
        end
        file.print "static #{cell.get_global_name.to_s.upcase}: #{get_rust_celltype_name(cell.get_celltype)}"
    end

    # 受け口構造体の初期化を生成
    # rodata セクション指定を削除
    def gen_rust_entryport_structure_initialize file, celltype, cell
        celltype.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then

                # 空のシグニチャの場合は、初期化を生成しない
                if port.get_signature.get_function_head_array.length == 0 then
                    next
                end

                # 受け口構造体の初期化を生成
                # 一つの受け口構造体がもつセルは１つ
                file.print "pub static #{port.get_name.to_s.upcase}FOR#{cell.get_global_name.to_s.upcase}: #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(celltype)} = #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(celltype)} {\n"
                file.print "\tcell: &#{cell.get_global_name.to_s.upcase},\n"
                file.print "};\n\n"
            end
        }
    end

    # セル構造体の変数フィールドの定義を生成
    def gen_rust_cell_structure_variable file, celltype
        if celltype.get_var_list.length != 0 then
            file.print "\tvariable: &'static TECSVariable<#{get_rust_celltype_name(celltype)}Var>,\n"
        end
    end

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
                file.print "&'a #{c_type_to_rust_type(attr.get_type)},\n"
                # str = c_type_to_rust_type(attr.get_type)
                # 属性や変数のフィールドに構造体がある場合は，ライフタイムを付与する必要がある
                # file.print "&'a #{str},\n"
            end
        }
    end

    # ロックガード構造体の変数への参照の定義を生成
    def gen_rust_lock_guard_structure_variable file, celltype
        if celltype.get_var_list.length != 0 then
            file.print "\tpub var: TECSVarGuard<'a, #{get_rust_celltype_name(celltype)}Var>,\n"
        end
    end

    def gen_use_in_tecs_global_rs file
        # file.print("use awkernel_lib::time::Time;\n")
    end

    # awkernelのTime型など、defaultの実装がない型への特別な対応を生成する
    def gen_default_impl_for_custom_struct file, struct
        file.print("impl Default for #{camel_case(snake_case(struct.get_name.to_s.sub(/^_+/, "")))} {\n")
        file.print("\tfn default() -> Self {\n")
        file.print("\t\tSelf {\n")
        struct.get_members_decl.get_items.each do |m|
            if @@non_default_impl_type_list.include?(c_type_to_rust_type(m.get_type)) then
                # defaultの実装がない型の場合は、特別な値を生成する
                case c_type_to_rust_type(m.get_type)
                    when "awkernel_lib::time::Time"
                        file.print("\t\t\t#{m.get_name}: awkernel_lib::time::Time::zero(),\n")
                    else
                        file.print("\t\t\t#{m.get_name}: Default::default(),\n")
                end
            else
                # defaultの実装がある型の場合は、Default::default()を生成する
                file.print("\t\t\t#{m.get_name}: Default::default(),\n")
            end
        end
        file.print("\t\t}\n")
        file.print("\t}\n")
        file.print("}\n\n")
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

    end

    def gen_rust_get_cell_ref file, celltype, callport_list, use_jenerics_alphabet
        # セルタイプに受け口がない場合は，生成しない
        # 受け口がないならば，get_cell_ref 関数が呼ばれることは現状無いため
        celltype.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then
                jenerics_flag = true
                file.print "impl"

                # impl のジェネリクスを生成
                callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
                    # 呼び口が動的ディスパッチの場合は、ジェネリクスを生成しない
                    if check_gen_dyn_for_port(callport) == nil then
                        if jenerics_flag then
                            jenerics_flag = false
                            file.print "<#{alphabet}: #{get_rust_signature_name(callport.get_signature)}"
                        else
                            file.print ", #{alphabet}: #{get_rust_signature_name(callport.get_signature)}"
                        end
                    end
                end

                file.print ">" if jenerics_flag == false

                # impl する型を生成
                file.print " #{get_rust_celltype_name(celltype)}"
                if check_only_entryport_celltype(celltype) then
                else
                    impl_first = true
                    callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
                        if check_gen_dyn_for_port(callport) == nil then
                            if impl_first then
                                impl_first = false
                                file.print "<#{alphabet}"
                            else
                                file.print ", #{alphabet}"
                            end
                        end
                    end
                    file.print ">" if impl_first == false
                end
                file.print " {\n"
                # インライン化
                file.print "\t#[inline]\n"

                # get_cell_ref 関数の定義を生成
                file.print "\tpub fn get_cell_ref"

                # セルタイプに変数がある場合は、引数にnodeをとる
                if celltype.get_var_list.length != 0 then
                    # ノードのライフタイムアノテーションは 'node とする
                    file.print "<'node>(&'static self, node: &'node mut awkernel_lib::sync::mutex::MCSNode<#{get_rust_celltype_name(celltype)}Var>) -> "
                else
                    file.print "(&'static self) -> "
                end

                file.print "LockGuardFor#{get_rust_celltype_name(celltype)}"

                # TECS/Rust において、dyn な呼び口は、ジェネリクス参照ではなくトレイトオブジェクトへの参照として表現される
                # そのため、use_jenerics_alphabet にトレイトオブジェクトが入っている場合は、その生成をスキップする
                # セルタイプ構造体にライフタイムアノテーションが必要かどうか判定する(必要 -> 呼び口を持っている)
                # TODO: ライフタイムアノテーションの判定は厳格にする必要がある
                # check_lifetime_annotation_for_celltype_structure から変更
                if check_only_entryport_celltype(celltype) then
                else
                    lock_guard_first = true
                    if celltype.get_var_list.length != 0 then
                        file.print "<'node"
                        lock_guard_first = false
                    end
                    # use_jenerics_alphabet と callport_list の要素数が等しいことを前提としている
                    callport_list.zip(use_jenerics_alphabet).each do |callport, alphabet|
                        if check_gen_dyn_for_port(callport) == nil then
                            if lock_guard_first then
                                lock_guard_first = false
                                file.print "<#{alphabet}"
                            else
                                file.print ", #{alphabet}"
                            end
                        end
                    end
                    file.print ">" if lock_guard_first == false
                end

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

    # 変数構造体と TECSVariable enum の初期化を生成
    def gen_rust_variable_structure_initialize file, cell
        if @celltype.get_var_list.length != 0 then
            file.print "static #{cell.get_global_name.to_s.upcase}VAR: TECSVariable<#{get_rust_celltype_name(cell.get_celltype)}Var> = TECSVariable::"

            # セルに排他制御が必要かどうか
            if check_exclusive_control_for_cell(cell) == true then
                file.print "Mutexed(awkernel_lib::sync::mutex::Mutex::new(\n"
            else
                file.print "Raw(TECSSyncVar { unsafe_var: core::cell::UnsafeCell::new(\n"
            end

            file.print "\t#{get_rust_celltype_name(cell.get_celltype)}Var {\n"
            gen_comments_safe_reason file, cell
            # 変数構造体のフィールドの初期化を生成
            gen_rust_variable_structure_field_initialize(file, cell)

            if check_exclusive_control_for_cell(cell) == true then
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

    def gen_use_for_impl_file file, celltype
        super(file, celltype)
        file.print "use awkernel_lib::sync::mutex::MCSNode;\n"
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

        # 変数があるかどうか
        # awkernelでは、変数への参照を必ず持つため、trueを返す
        return true if celltype.get_var_list.length != 0

        return false
    end

    # セルタイプに受け口がある場合，受け口関数を生成する
    def gen_rust_entryport_function file, celltype, callport_list
        # セルタイプに受け口がある場合，impl を生成する
        celltype.get_port_list.each{ |port|
            if port.get_port_type == :ENTRY then
                sig = port.get_signature

                file.print "impl #{camel_case(snake_case(port.get_signature.get_global_name.to_s))} for #{camel_case(snake_case(port.get_name.to_s))}For#{get_rust_celltype_name(celltype)}{\n\n"

                sig_param_str_list, _, lifetime_flag = get_sig_param_str sig

                # 空の関数を生成
                sig.get_function_head_array.each{ |func_head|
                    # 関数のインライン化
                    if port.is_inline? then
                        file.print "\t#[inline]\n"
                    end
                    file.print "\tfn #{get_rust_function_name(func_head)}"
                    # おそらく不要
                    # if lifetime_flag then
                    #     file.print "<'a>"
                    # end
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
                        if celltype.get_var_list.length != 0 then
                            # ロックガードで覆う場合の生成
                            file.print "\t\tlet mut node = MCSNode::new();\n"
                            file.print "\t\tlet mut lg = self.cell.get_cell_ref(&mut node);\n"
                        else
                            file.print "\t\tlet mut lg = self.cell.get_cell_ref();\n"
                        end
                    end
                    file.print "\n"
                    file.print"\t}\n"
                }

                file.print "}\n\n"

            else
            end
        }
    end

    # Cargo.toml の設定を変更する
    def change_cargo_toml path
        cargo_toml_path = "#{path}/Cargo.toml"

        awkernel_dependencies = <<~'EOS'
[dependencies.awkernel_async_lib]
path = "../../../awkernel_async_lib"
default-features = false

[dependencies.awkernel_lib]
path = "../../../awkernel_lib"
default-features = false
        EOS

        File.open(cargo_toml_path, "a") do |file|
            file.puts ""
            file.puts awkernel_dependencies
        end

        super(path)
    end

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
            copy_gen_files_to_cargo "tecs_variable.rs", nil
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
        # gen_tecs_ex_ctrl_rs

        # TODO: 必要なときにのみ生成するようにする
        # gen_tecs_mutex_rs

        # TODO: 必要なときにのみ生成するようにする
        # gen_tecs_semaphore_rs

        # gen_tecs_print_rs

        # copy_gen_files_to_cargo "kernel_cfg.rs", nil

        gen_tecs_variable_rs
    end

end
