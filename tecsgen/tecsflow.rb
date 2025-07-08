#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
#  TECSFlow
#      TECS Flow Analyzer
#  
#   Copyright (C) 2008-2019 by TOPPERS Project
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
#   $Id: tecsflow.rb 3076 2019-06-09 06:45:27Z okuma-top $
#++
$tecsflow_base_path = File.dirname( File.expand_path __FILE__ )

require 'optparse'
$TECSFLOW = true
$title = "tecsflow"
$tool_version = "1.G.0"

$rustflow = false
$rustflow_option = nil
$repeat = false

$cell_list_hash = {}
$flow_json_hash_init_flag = false # flow_json_hash の初期化を行うかどうかのフラグ
$flow_json_hash = {}
$flow_stack = [] # 各 active cell から出力されるコールフローに関わる cell を格納するスタック (次の active cell のコールフローになるとリセットされる)
$path_item_stack = [] # 各 active cell から出力されるコールフローをスタックで保存するための変数 (次の active cell のコールフローになるとリセットされる)
$reentry_cell_list = {}

require "#{$tecsflow_base_path}/flowlib/classes.rb"
require "#{$tecsflow_base_path}/tecslib/version.rb"
require "#{$tecsflow_base_path}/tecsgen.rb"

# FMP3+TECS/Rust用の require
$tecsgen_base_path = $tecsflow_base_path
$library_path = [ $tecsgen_base_path ]
require "#{$tecsflow_base_path}/tecslib/core/syntaxobj/node.rb"
require "#{$tecsflow_base_path}/tecslib/core/plugin.rb"
require "#{$tecsflow_base_path}/tecslib/plugin/ClassPlugin.rb"
require "#{$tecsflow_base_path}/tecslib/plugin/FMPPlugin.rb"

def analyze_option

  ###  tecsgen コマンドオプション解析  ###
  ARGV.options {|parser|
    parser.banner = "Usage: tecsflow [options]"
    parser.on('-g', '--gen=dir',     'generate dir') { |dir|
      $gen = $gen_base = dir
    }
    parser.on('-h', '--help',     'help') {
      puts parser.help
      exit 1
    }
    parser.on( '--version', 'print version') {
      $print_version = true
    }
    parser.on('-r', '--rust=option',     'select only or both') { |option|
      if option == "only" then
        $rustflow = true
        $rustflow_option = "only"
      elsif option == "both" then
        $rustflow = true
        $rustflow_option = "both"
      else
        print "invalid option for --rust\n"
        exit 1
      end 
    }
    parser.version = "#{$version}"
    parser.release = nil
    parser.parse!
  }

end # analyze_option

  # 文字列を snake_case に変換する
  def snake_case(input_string)
    input_string.gsub(/([a-z0-9])([A-Z])/, '\1_\2').gsub(/([A-Z])([A-Z][a-z])/, '\1_\2').downcase
  end
  
  # 文字列を camelCase に変換する
  def camel_case(input_string)
    input_string.split('_').map(&:capitalize).join
  end
  
  def get_rust_celltype_name celltype
    return camel_case(snake_case(celltype.get_global_name.to_s))
  end

addtional_option_parser = nil
no_tecsgen_option = true
TECSGEN.init addtional_option_parser, no_tecsgen_option
analyze_option

tecsgen = TECSGEN.new

$tecsgen_dump_file_name = "#{$gen}/tecsgen.rbdmp"
$tcflow_dump_file_name = "#{$gen}/tcflow.rbdmp"
if $rustflow then
  $tcflow_dump_file_name = "#{$gen}/rustflow.rbdmp"
end
$root_namespace = nil
$tcflow_funclist = nil

def print_indent( level )
  if level > 0 then
    print "    " * level
    return level
  else
    return - level
  end
end

class Namespace
  include Locale_printer
  def self.set_root root
    @@root_namespace = root
  end

  # def get_cell_list
  #   return @cell_list
  # end

  def create_cell_list_json_hash

    # 名前空間の数だけ再帰的に呼ばれてしまうため、一度だけ呼ぶようにする
    if $flow_json_hash_init_flag == false then
      $flow_json_hash_init_flag = true
    else
      return
    end

    name_space_list = @@root_namespace.get_namespace_list

    name_space_list.each do |name_space|
      name_space.get_cell_list.each do |cell|
        cellname = cell.get_global_name.to_s
        celltype = cell.get_celltype.get_name.to_s
        cell_obj = {
          "Cell": cellname,
          "Celltype": celltype,
          "ExclusiveControl": "false",
          "Accessed": []
        }
        $flow_json_hash[cellname] = cell_obj
      end
    end
  end

  #=== print_all_cells
  # print all call flow beginning with active cell's call port function
  def print_all_cells
    # for each active cell
    # print @cell_list

    create_cell_list_json_hash

  	@cell_list.each{|cell|
      # print "cell: #{cell.get_name}\n"
 			celltype = cell.get_celltype
 			call_funcs = {}
  		if celltype.is_active? then
  			if ! celltype.kind_of? CompositeCelltype then
          $flow_stack = []
          $flow_stack.push [cell, 0]
          print "[active cell] #{cell.get_namespace_path}"
          print_locale cell.get_locale
          print "\n"
		  		cell.get_join_list.get_items.each{ |j|
		  			if j.get_definition.kind_of? Port then
		  				port = j.get_definition
			  			port.get_signature.get_function_head_array.each{ |f|
			  			  func_name = "->#{port.get_name}.#{f.get_name}__T".to_sym
                # print "func_name: #{func_name}\n"
                # if $rustflow then
                #   func_name = "#{snake_case(port.get_name.to_s)}.#{f.get_name}".to_sym
                # end
			  			  call_funcs[ func_name ] = false
		  				}
		  			end
		  		}
          # isn't the call port function called from entry port function ?
          #  if called, it's not actually active (task main, handler main is not called from entry function)
  				celltype.get_port_list.each{ |ep|
  					if ep.get_port_type == :ENTRY then
  						ep.get_signature.get_function_head_array.each{ |f|
  							ep_func = "#{celltype.get_global_name}_#{ep.get_name}_#{f.get_name}".to_sym
                if $rustflow then
                  ep_func = "#{camel_case(snake_case(ep.get_name.to_s))}For#{get_rust_celltype_name(celltype)}.#{snake_case(f.get_name.to_s)}".to_sym
                  # print "print_all_cells: rustflow is true\n"
                end
	  						if $tcflow_funclist[ ep_func ] then
	  							$tcflow_funclist[ ep_func ].get_call_funcs.each{ |cf, cff|
                    if call_funcs[cf] == false then
                      # printf "#{ep_func} calls #{cf}\n"
                      call_funcs[cf] = true
                    end
	  							}
	  						else
	  							print "ep_func #{ep_func} not found. why not defined ?\n"
	  						end
  						}
  					end
  				}
          call_funcs.each{ |call_func_name, v|
            if v == false then   # not called from entry port func
              # print " #{f} \n"
              # decompose
              indent_level = 1
              no_caller_cell = true
              cell.print_call_func_flow no_caller_cell, call_func_name, indent_level
            end
          }
		  	end
	  	end
  	}
  	@namespace_list.each{|ns|
  		ns.print_all_cells
  	}
  	if false then
  		$tcflow_funclist.each{|name, func|
  			print name, "\n"
  			if func.kind_of? TCFlow::Function then
	  			func.get_call_funcs.each{ |cname,cfunc|
  					print "  -> ", cname, "\n"
  				}
  			end
  		}
  	end
  end
end

class Cell
  include Locale_printer
  @@printed_func_nsp_list = {}    # function path in CDL like format
  @@printed_cell_list = {}
  @@printed_celltype_list = {}
  # $repeat = false

  def self.print_unused_func
    parent_cell = []
    indent_level = 1
    @@printed_cell_list.keys.each{ |cell|
      cell_printed = false
      ct = cell.get_celltype
      if cell.is_in_composite? then
        # print "unreferenced in composite #{ct.get_name} #{cell.get_name}\n"
        next
      end
      # if @@printed_celltype_list[ ct ] == true then
      #   next
      # end
      # @@printed_celltype_list[ ct ] = true
      ct.get_port_list.each{ |port|
        next if port.get_port_type == :CALL
        entry_port_name = port.get_name
        port.get_signature.get_function_head_array.each{ |func|
          func_name = func.get_name
          # func_nsp = get_function_nsp port_name, func_name, parent_cell
          # if @@printed_func_nsp_list[ func_nsp ] != true then
          # end
          ep_func = "#{ct.get_global_name}_#{entry_port_name}_#{func_name}".to_sym

          if $rustflow then
            ep_func = "#{camel_case(snake_case(entry_port_name.to_s))}For#{get_rust_celltype_name(ct)}.#{snake_case(func_name.to_s)}".to_sym
            # print "print_all_cells: rustflow is true\n"
          end
          # print "  ", ep_func, "\n"
          if $tcflow_funclist[ ep_func ].kind_of? TCFlow::Function then
            func = $tcflow_funclist[ ep_func ]
            if ! func.is_printed? then
              #if cell_printed == false then
              #  cell_printed = true
              # if cell.get_namespace_path == nil then
              #   cell.show_tree 0
              # end
              if $rustflow then
                print "[unreferenced entry function] #{ep_func.to_s}"
              else
                print "[unreferenced entry function] #{cell.get_namespace_path}.#{entry_port_name}.#{func_name}"
              end
              #end
              cell.print_entry_func_flow entry_port_name, func_name, indent_level, parent_cell
            end
          end
        }
      }
    }
  end

  # TODO: 呼び口配列や受け口配列に対応していない
  def create_path_item_hash indent_level, no_caller_cell, call_port_name, call_subsc, callee_cell, entry_port_name, callee_subsc, func_name

    path_item = {
      "CellName": callee_cell.get_global_name,
      "Celltype": callee_cell.get_celltype.get_name,
      "Callport": call_port_name, # この値は、自分のセルの呼び口を入れたいが、この時点では呼び元のセルのポート名であるため、正しくない
      "Calleeport": entry_port_name, # この値は、自分のセルの受け口を入れたいが、この時点では呼び元のセルの呼び先ポート名であるため、正しくない
      "Function": func_name, # この値は、自分のセルの対応する関数名を入れたいが、呼び元のセルの呼び口関数名であるため、正しくない
    }

    while $path_item_stack.any? && $path_item_stack.last[1] >= indent_level
      $path_item_stack.pop
    end

    $path_item_stack.push [path_item, indent_level]

    path_item_stack_copy = Marshal.load(Marshal.dump($path_item_stack))

    # タスクの優先度を取得する
    # タスク以外のアクティブセルの場合や、priority 属性が無い場合、0 とする
    task_priority = 0
    $flow_stack.first[0].get_celltype.get_attribute_list.each{ |attr|
      if attr.get_name.to_s == "priority" then
        task_priority = $flow_stack.first[0].get_attr_initializer(:priority)
      end
    }

    # if $flow_stack.first[0].get_attr_initializer(:priority) != nil then
    #   task_priority = $flow_stack.first[0].get_attr_initializer(:priority)
    # end

    # $path_item_stack を全て accessed_item に追加
    accessed_item = {
      "ActiveCell": $flow_stack.first[0].get_global_name,
      "Priority": task_priority,
      "Celltype": $flow_stack.first[0].get_celltype.get_name,
      "Callport": $path_item_stack[0][0][:Callport],
      "Calleeport": $path_item_stack[0][0][:Calleeport],
      "Function": $path_item_stack[0][0][:Function],
      "Path": []
    }

    trace_list = []

    # 1つ先のセルの Callport, Calleeport, Function を取得 (ここで上記の正しくない値をもつキーを正しい値に更新する)
    # Path キーの値を作成している
    path_item_stack_copy.each_with_index{ |path_item_temp, i|
      break if i == path_item_stack_copy.length - 1

      # ループ構造になっているセルを検出
      if trace_list.include? path_item_temp[0][:CellName].to_s then
        $reentry_cell_list[path_item_temp[0][:CellName].to_s] = $path_item_stack[i-1][0][:CellName].to_s
      else
        trace_list.push path_item_temp[0][:CellName].to_s
      end

      path_item_temp[0][:Callport] = $path_item_stack[i+1][0][:Callport]
      path_item_temp[0][:Calleeport] = $path_item_stack[i+1][0][:Calleeport]
      path_item_temp[0][:Function] = $path_item_stack[i+1][0][:Function]
      accessed_item[:Path].push path_item_temp[0]
    }

    # print "$path_item_stack = #{$path_item_stack}\n"

    $flow_json_hash[$path_item_stack.last[0][:CellName].to_s][:Accessed] << Marshal.load(Marshal.dump(accessed_item))

    # print "accessed_item[#{callee_cell.get_global_name}] = #{$flow_json_hash[$path_item_stack.last[0][:CellName].to_s][:Accessed]}\n"
    # print "accessed_item[rProcessor1Symmetric_Led}] = #{$flow_json_hash["rProcessor1Symmetric_Led"][:Accessed]}\n"


    while $flow_stack.any? && $flow_stack.last[1] >= indent_level
      $flow_stack.pop
    end

    $flow_stack.push [callee_cell, indent_level]

  end

  def get_function_nsp port_name, func_name, parent_cell
    if @in_composite == false then
      nsp = get_namespace_path.to_s.sub( /^::/, "")
      return "#{nsp}.#{port_name}.#{func_name}".to_sym
    else
      len = parent_cell.length
      if parent_cell[0] == nil then
        # Bug trap
        print "\nname=", @name, ", len=", len, " nsp=", get_namespace_path, "\n"
        nsp = "__" + @name.to_s
      else
        nsp = parent_cell[0].get_namespace_path.to_s
      end
      i = 1
      while i < len
        nsp = nsp + '_' + parent_cell[i].get_name.to_s
        i+=1
      end
      return "#{nsp}_#{@name}.#{port_name}.#{func_name}".to_sym
    end
  end

  def extract_printed_func_json func_nsp
    legion_cell_name = func_nsp.to_s.split(".")[0]
    entry_port_name = func_nsp.to_s.split(".")[1]
    entry_func_name = func_nsp.to_s.split(".")[2]

    legion_name = legion_cell_name.split("::").first
    cell_name = legion_cell_name.split("::").last
    cell_name.prepend(legion_name + "_")

    # Path のなかに存在する func_nsp の次以降の Path を取得
    results = []
    $flow_json_hash.each do |cell, flow|
      flow[:Accessed].each do |accessed|
        accessed[:Path].each_with_index do |path, i|
          if path[:Calleeport].to_s == entry_port_name && path[:Function].to_s == entry_func_name then
            accessed[:Path][i+1..-1].each do |path|
              break if accessed[:Path][i+1][:CellName] != cell_name.to_sym
              # next if accessed[:Path][i+1][:CellName] != cell_name.to_sym
              # print "check\n"
              results << path
            end
          end
        end
      end
    end

    # ActiceCell と Path をまたぐように fucn_nsp が存在している場合の処理
    if results.length == 0 then
      $flow_json_hash.each do |cell, flow|
        flow[:Accessed].each do |accessed|
          if accessed[:Calleeport].to_s == entry_port_name && accessed[:Function].to_s == entry_func_name then
            accessed[:Path].each_with_index do |path, i|
              results << path
            end
          end
        end
      end
    end

    return results

  end

  def print_entry_func_flow entry_port_name, func_name, indent_level, parent_cell
    func_nsp = get_function_nsp entry_port_name, func_name, parent_cell
    # print "\nentry:", func_nsp, "\n"
    @@printed_cell_list[ self ] = true
    ###### ここで printed 判断しているが、現在がリーフであるかどうかとは同義ではない
    if @@printed_func_nsp_list[ func_nsp ] then
      # print "\n"
      # print_indent indent_level
      # print func_nsp
      print ": printed\n"
      # TODO: printed のときに json に上手く出力できるようにする
      # print "func_nsp: ", func_nsp, "\n"
      # print "self.get_name: ", self.get_name, "\n"

      printed_func_json = extract_printed_func_json func_nsp

      # print "$flow_json_hash[#{self.get_name.to_s}][:Accessed][:Path]: ", $flow_json_hash[self.get_name.to_s][:Accessed][:Path], "\n"
      # $flow_json_hash[self.get_name.to_s][:Accessed][:Path] << Marshal.load(Marshal.dump(printed_func_json))
      # print "result: ", result, "\n"
      # print "printed_func_json: ", printed_func_json, "\n"

      current_cell = self
      printed_func_json.each do |path|
        calleeport_join = current_cell.get_join_list.get_item(path[:Callport].to_sym)
        if calleeport_join.get_port_name.to_s != path[:Calleeport].to_s then
          puts "Printed function path json is not generated successfully."
          break
        end
        current_cell = calleeport_join.get_cell

        # TODO: 呼び口配列や受け口配列に対応していない
        create_path_item_hash indent_level, false, path[:Callport], nil, current_cell, path[:Calleeport], nil, path[:Function]
        
      end

      return
    end
    @@printed_func_nsp_list[ func_nsp ] = true
    if ! @celltype.kind_of? CompositeCelltype
      ep_func = "#{@celltype.get_global_name}_#{entry_port_name}_#{func_name}".to_sym
      if $rustflow then
        ep_func = "#{camel_case(snake_case(entry_port_name.to_s))}For#{get_rust_celltype_name(@celltype)}.#{snake_case(func_name.to_s)}".to_sym
        # print "print_entry_func_flow: rustflow is true\n"
      end
      if $tcflow_funclist[ ep_func ] then
        function = $tcflow_funclist[ ep_func ]
        print_locale function.get_locale
        print "\n"
        function.set_printed
        function.get_call_funcs.each{ |call_func_name, func|
          # print "call_func_name: #{call_func_name}\n"
          # print "func: #{func}\n"
          # print "#{indent}#{fname} \n"
          # decompose
          no_caller_cell = true
          print_call_func_flow no_caller_cell, call_func_name, indent_level, parent_cell
        }
      else
        print "\n"
        indent_level = print_indent indent_level
        print "not found '#{ep_func}' !!!\n"
      end
    else
      cj = @celltype.find_export entry_port_name
      cell = cj.get_cell
      ep_name = cj.get_cell_elem_name
      print " == [inner]#{cell.get_name}.#{ep_name}"
      parent_cell = parent_cell.dup
      # print "\n#{@name} PUSH\n"
      parent_cell.push self
      # parent_cell.each{|c| print c.get_name, "\n" }
      cell.print_entry_func_flow ep_name, func_name, indent_level, parent_cell
    end
    ###### 出力が終わる、つまりリーフの時はここで終了する
    ###### リーフ以外のケースにおいても、通ることがある
    # print "checked\n"
  end

  def print_call_func_flow no_caller_cell, call_func_name, indent_level, parent_cell = []
    # print "call_func_name: #{call_func_name}\n"
    m = TECSFlow.analyze_call_port_func_name call_func_name
    # print "m: "
    # print m
    # print "\n"
    if m then
      call_port = m[0]
      function = m[1]
      call_subsc = m[2]
      # print "print_call_func_flow: #{call_func_name} => #{call_port}.#{function}\n"
      # p "call_subsc=", call_subsc
      ##### 現在のケースは call_subsc は nil
      if call_subsc == nil then
        join = get_join_list.get_item call_port
        print_call_func_flow_sub indent_level, no_caller_cell, call_port, call_subsc, function, join, parent_cell
      else
        # print "call_subsc=#{call_subsc}\n"
        join_0 = get_join_list.get_item call_port
        if join_0 then
          am = join_0.get_array_member2
          call_subsc = 0
          am.each{ |join|
            print_call_func_flow_sub indent_level, no_caller_cell, call_port, call_subsc, function, join, parent_cell
            call_subsc += 1
          }
        else
          print_call_func_flow_sub indent_level, no_caller_cell, call_port, call_subsc, function, join, parent_cell
        end
      end
    else
      # non TECS function
      func = $tcflow_funclist[ call_func_name ]
      if func.kind_of? TCFlow::Function then
        if func.is_printed? then
          indent_level = print_indent indent_level
          print func.get_name, ": printed\n"
        else
          indent_level = print_indent indent_level
          print "#{call_func_name}"
          print_locale func.get_locale
          print " [Function Out of TECS]\n"
          func.set_printed
          func.get_call_funcs.each{ |cf, cff|
            no_caller_cell = false
            print_call_func_flow no_caller_cell, cf, indent_level + 1, parent_cell
          }
        end
      else
        indent_level = print_indent indent_level
        print call_func_name, ": [Function Out of TECS, not defined]\n"
      end
        # print "#{"    "*indent_level}fail to analyze #{call_func_name}\n"
    end
  end

  def print_call_func_flow_sub indent_level, no_caller_cell, call_port, call_subsc, function, join, parent_cell
    # print "j = join : #{join}\n"
    # print "parent_cell = ", parent_cell, "\n"
    # print "indent_level = ", indent_level, "\n"
    # print "no_caller_cell = ", no_caller_cell, "\n"
    # print "call_port = ", call_port, "\n"
    # print "call_subsc = ", call_subsc, "\n"
    # print "function = ", function, "\n"
    # print "join = ", join.get_name, "\n"

    j = join
    if j != nil then
      if ! $unopt then
        callee_cell = j.get_rhs_cell
        # print "callee_cell = ", callee_cell.get_name, "\n"
        callee_port = j.get_rhs_port.get_name
        # print "callee_port = ", callee_port, "\n"
        callee_subsc = j.get_rhs_subscript
        # print "callee_subsc = ", callee_subsc, "\n"
      else
        callee_cell = j.get_rhs_cell1
        # print "callee_cell = ", callee_cell.get_name, "\n"
        callee_port = j.get_rhs_port1
        # print "callee_port = ", callee_port, "\n"
        callee_subsc = j.get_rhs_subscript1
        # print "callee_subsc = ", callee_subsc, "\n"
      end
      print_flow indent_level, no_caller_cell, call_port, call_subsc, callee_cell, callee_port, callee_subsc, function
      callee_cell.print_entry_func_flow callee_port, function, indent_level + 1, parent_cell
    else
      # print "parent_cell = ", parent_cell, "\n"
      if parent_cell.length > 0 then
        # print "len = ", parent_cell.length, "\n"
        composite = parent_cell.last.get_celltype
        compjoin = nil
        # search from exporting ports to find call port which matches inner cell's call port
        composite.get_port_list.each{|cj|
          if cj.get_cell.get_name == @name && cj.get_cell_elem_name == call_port then
            compjoin = cj
            break
          end
        }
        if compjoin then
          indent_level = print_indent indent_level
          if no_caller_cell == false then
            print "[inner]#{@name}."
          end
          print "#{call_port} == "
          j = parent_cell.last.get_join_list.get_item compjoin.get_name
          # print "j = ", j, "\n"
          if j != nil then
            if ! $unopt then
              callee_cell = j.get_rhs_cell
              callee_port = j.get_rhs_port.get_name
              callee_subsc = j.get_rhs_subscript
            else
              callee_cell = j.get_rhs_cell1
              callee_port = j.get_rhs_port1
              callee_subsc = j.get_rhs_subscript1
            end
            no_caller_cell = false
            parent_cell.last.print_flow (-indent_level), no_caller_cell, call_port, call_subsc, callee_cell, callee_port, callee_subsc, function
            pc = parent_cell.dup
            # print "#{pc.last.get_name} POP\n"
            pc.pop
            callee_cell.print_entry_func_flow callee_port, function, indent_level + 1, pc
            # break
          else
            # print "recursive case\n"
            # recursive case, parent's port is joined to grand parent's exporting port.
            cf_name = "->#{compjoin.get_name}.#{function}__T".to_sym
            pc = parent_cell.dup
            # print "func = ", cf_name, "\n"
            # print "#{pc.last.get_name} POP\n"
            pc.pop
            # print parent_cell.last.get_name, ".", compjoin.get_name, ".", function, "\n"
            if indent_level > 0 then
              tmp_indent_level = - indent_level
            else
              tmp_indent_level = indent_level
            end
            no_caller_cell = false
            parent_cell.last.print_call_func_flow no_caller_cell, cf_name, tmp_indent_level, pc
            # break
          end
        else
          # print "name=", @name, "  "
          # composite.get_port_list.each{|cj|
          #  print cj.get_name, ", "
          # }
          print "\n"
          indent_level = print_indent indent_level
          print "#{@name}.#{call_port} not found in composite #{parent_cell.last.get_name}\n"
          # break
        end
      else
        indent_level = print_indent indent_level
        print "#{@name}.#{call_port} not joined\n"
      end   # end while
    end
  end

  # c_task_body.main などの呼び口関数や受け口関数を print する関数
  def print_name no_cell_name, port_name, subsc, func_name
    if ! no_cell_name then
      nsp = get_namespace_path.to_s.sub( /^::/, "")
      # pp nsp.class.name
      # rustflow の場合は、セル名.受け口名.関数名 ではなく、受け口構造体名.関数名 なるように if文追加
      if nsp != "" then
        print nsp, "."
      else
        print @name, "."
      end
    end

    print port_name
    if subsc then
      print '[', subsc, ']'
    end
    print ".", func_name
  end

      # c_task_body.main などの呼び口関数や受け口関数を print する関数
  def print_rust_name no_cell_name, port_name, subsc, func_name
    if ! no_cell_name then
      nsp = get_namespace_path.to_s.sub( /^::/, "")
      # pp nsp.class.name
      # rustflow の場合は、セル名.受け口名.関数名 ではなく、受け口構造体名.関数名 なるように if文追加
      if nsp != "" then
        print nsp.upcase, ":"
      else
        print @name.upcase, ":"
      end
    end

    print port_name
    if subsc then
      print '[', subsc, ']'
    end
    print ".", func_name
  end

  def print_flow indent_level, no_caller_cell, call_port_name, call_subsc, callee_cell, entry_port_name, callee_subsc, func_name
    # print "indent_level = ", indent_level, "\n"
    # print "no_caller_cell = ", no_caller_cell, "\n"
    # print "call_port_name = ", call_port_name, "\n"
    # print "call_subsc = ", call_subsc, "\n"
    # print "callee_cell = ", callee_cell, "\n"
    # print "callee_cell.get_name = ", callee_cell.get_name, "\n"
    # print "entry_port_name = ", entry_port_name, "\n"
    # print "callee_subsc = ", callee_subsc, "\n"
    # print "func_name = ", func_name, "\n"
    
    create_path_item_hash indent_level, no_caller_cell, call_port_name, call_subsc, callee_cell, entry_port_name, callee_subsc, func_name
    
    indent_level = print_indent indent_level
    no_cell_name = no_caller_cell
    if $repeat == false then
      if $rustflow then
        rust_call_port_name = "#{snake_case(call_port_name.to_s)}".to_sym
        print_rust_name no_cell_name, rust_call_port_name, call_subsc, func_name
      else
        print_name no_cell_name, call_port_name, call_subsc, func_name
      end
      print " => "
      no_cell_name = false
      if $rustflow then
        rust_entry_port_structure = "#{camel_case(snake_case(entry_port_name.to_s))}For#{get_rust_celltype_name(callee_cell.get_celltype)}".to_sym
        callee_cell.print_rust_name no_cell_name, rust_entry_port_structure, callee_subsc, func_name
      else
        callee_cell.print_name no_cell_name, entry_port_name, callee_subsc, func_name
      end
    end

    if $rustflow_option == "both" || $repeat == true then
      if $repeat == false then
        print "\n"
      end
      indent_level = print_indent indent_level
      no_cell_name = no_caller_cell
      print_name no_cell_name, call_port_name, call_subsc, func_name
      print " => "
      no_cell_name = false
      callee_cell.print_name no_cell_name, entry_port_name, callee_subsc, func_name
    end
  end
end

# class FlowTreeNode
#   attr_accessor :value, :children, :parent, :callport_name, :callfunc_name, :cellname, :entryport_name

#   def initialize(value)
#     @value = sanitize_value(value)
#     @children = []
#     @parent = nil
#     @callport_name, @callfunc_name, @cellname, @entryport_name = split_flow_line(value)
#   end

#   def add_child(child)
#     child.parent = self
#     @children << child
#   end

#   def display(level = 0)
#     puts "#{'  ' * level}#{value}"
#     children.each { |child| child.display(level + 1) }
#   end

#   def find_node(value)
#     return self if @value.include?(value)

#     children.each do |child|
#       result = child.find_node(value)
#       return result if result
#     end
#     nil
#   end

#   def find_nodes_by_cellname(target_cellname)
#     results = []
#     traverse do |node|
#       results << node if node.cellname == target_cellname
#     end
#     results
#   end

#   def flow_from_root_to_node(node_or_nodes)
#     nodes = [node_or_nodes].flatten
#     nodes.map do |node|
#       path = node.path_to_root
#       path.map do |n|
#         if n.parent
#           "#{n.callport_name}.#{n.callfunc_name} => #{n.cellname}.#{n.entryport_name}.#{n.callfunc_name}"
#         else
#           n.value
#         end
#       end.join(' -> ')
#     end
#   end

#   def traverse(&block)
#     yield self
#     children.each { |child| child.traverse(&block) }
#   end

#   def path_to_root
#     node = self
#     path = []
#     while node
#       path << node
#       node = node.parent
#     end
#     path.reverse
#   end

#   def formatted_path_to_root
#     path = path_to_root
#     path.map.with_index do |n, index|
#       if index == 0
#         n.value
#       elsif n.parent
#         "#{n.callport_name}.#{n.callfunc_name} => #{n.cellname}.#{n.entryport_name}.#{n.callfunc_name}"
#       end
#     end.compact.join(' -> ')
#   end

#   def sanitize_value(value)
#     # 正規表現を使って余分な部分を取り除く
#     value.sub(/\s*\(.*?\)\s*$/, '').sub(/: printed$/, '')
#   end

#   def root_value
#     node = self
#     node = node.parent while node.parent
#     node.value
#   end

#   private

#   def split_flow_line(line)
#     callport_name_in_flow = nil
#     callfunc_name_in_flow = nil
#     cellname_in_flow = nil
#     entryport_name_in_flow = nil

#     if line.include?("=>")
#       cfunc_statement = line.split("=>")[0].strip
#       callport_name_in_flow = cfunc_statement.split(".")[0].strip
#       callfunc_name_in_flow = cfunc_statement.split(".")[1].strip
#       efunc_statement = line.split("=>")[1].strip.sub(/: printed$/, '')
#       if efunc_statement.include?(":")
#         cellname_in_flow = efunc_statement.split(":")[0].strip
#         entryport_name_in_flow = efunc_statement.split(":")[1].split(".")[0].strip
#       else
#         cellname_in_flow = efunc_statement.split(".")[0].strip
#         entryport_name_in_flow = efunc_statement.split(".")[1].strip
#       end
#     end

#     return callport_name_in_flow, callfunc_name_in_flow, cellname_in_flow, entryport_name_in_flow
#   end
# end

module TECSFlow
  include Locale_printer
  # include FlowTreeNode
  require 'json'
  def self.main
    doing = "nothing"
    begin
      print "reading '#{$tecsgen_dump_file_name}'\n"
      doing = "file reading"
      mar_in = File.read( $tecsgen_dump_file_name )
      TCFlow::Function.load_funclist $tecsgen_dump_file_name
      doing = "Marshal.load"
      $root_namespace = Marshal.load( mar_in )
      # ここではクラス変数を設定していないため、それらを参照するメソッドは使用できないことに注意！
    rescue => e
			pp e
      print "fatal: fail to load '#{$tecsgen_dump_file_name}' in #{doing}\n"
      exit 1
    end

    begin
      print "reading '#{$tcflow_dump_file_name}'\n"
      # doing = "file reading"
      # mar_in = File.read( $tcflow_dump_file_name )
      # doing = "Marshal.load"
      # $tcflow_funclist = Marshal.load( mar_in )
      $tcflow_funclist = TCFlow::Function.load_funclist $tcflow_dump_file_name
      # funclist の出力
      # print "$tcflow_funclist = ", $tcflow_funclist, "\n"
      temp = $tcflow_funclist[:"ETaskbodyForTTaskbody.main"]
      # print "@name = ", temp.get_name, "\n"
      # print "@call_funcs = ", temp.get_call_funcs, "\n"
      # print "stop = ", temp.get_call_funcs[:'->cMotor.stop__T'], "\n"
    rescue
      print "fatal: fail to load '#{$tcflow_dump_file_name}' in #{doing}\n"
      exit 1
    end
    Namespace.set_root $root_namespace

    # cell_list = $root_namespace.get_cell_list
    # cell_hash = {}
    # cell_list.each{ |cell|
      # cell_hash[ cell.get_name ] = cell
      # print "cell = ", cell, "\n"
    # }
    # temp = cell_hash[:'Motor']
    # print "cell_name = ", temp.get_name, "\n"

    $root_namespace.print_all_cells
    print_unref_function

    json_list = []
    cell_list = []

    # cell_list = $root_namespace.get_cell_list
    # cell_list.each{ |cell|
    #   next if cell.get_celltype.is_active?
    #   json_list << $flow_json_hash[cell.get_name.to_s]
    # }

    name_space_list = $root_namespace.get_namespace_list
    
    # name_space_list.each do |name_space|
    #   print "name_space.get_name.to_s = ", name_space.get_name.to_s, "\n"
    # end

    # print "$flow_json_hash = #{$flow_json_hash}\n"

    name_space_list.each do |name_space|
      name_space.get_cell_list.each do |cell|
        cell_list << cell
        next if cell.get_celltype.is_active?
        # json_list << $flow_json_hash[cell.get_name.to_s]
        json_list << $flow_json_hash[cell.get_global_name.to_s]
      end
    end

    # print "json_list = #{json_list}\n"

    # cell_list.each do |cell|
    #   # print "cell.get_name.to_s = ", cell.get_name.to_s, "\n"
    #   print "cell.get_name.to_s = ", cell.get_global_name.to_s, "\n"
    # end

    analyze_deadlock json_list, cell_list

    json_file = File.open( "#{$gen}/tecsflow.json", "w" ) do |f|
      f.write(JSON.pretty_generate(json_list))
    end

    # json_file = File.open( "#{$gen}/tecsflow_temp.json", "w" ) do |f|
      # f.write(JSON.pretty_generate($flow_json_hash))
    # end

    # generate_json_file
  end

  def self.analyze_call_port_func_name fname
    m = /-\>(?<cp>\w+)(?<subsc>(\[\])*)\.(?<func>\w+)__T/.match fname.to_s
    if m then
      call_port = m[:cp].to_sym
      function = m[:func].to_sym
      subsc = m[:subsc]
      subsc = nil if subsc == ""
      return [ call_port, function, subsc ]
    else
      return nil
    end
  end

  def self.print_unref_function
    print "--- unreferenced entry functions ---\n"
    Cell.print_unused_func
    print "--- unreferenced C functions ---\n"
    TCFlow::Function.update
    $tcflow_funclist.each{ |fname, func|
      if func.kind_of? TCFlow::Function then
        if ! func.is_printed? && func.is_top? then
          print "[Function Out of TECS, unreferenced] ", func.get_name
          locale = func.get_locale
          Locale_printer::print_locale locale
          print "\n"
          # print " (", locale[0], " ", locale[1], ")\n"
          func.print_all_functions 0
        end
      # else
      #   print_indent 0
      #   print fname, "\n"
      end
    }
  end

  # def self.generate_json_file

  #   log_file = File.open( "#{$gen}/tecsflow.log", "w" )
  #   $stdout = log_file

  #   Cell.class_variable_set(:$repeat, true)
  #   Cell.class_variable_set(:@@printed_func_nsp_list, {})
  #   Cell.class_variable_set(:@@printed_cell_list, {})
  #   Cell.class_variable_set(:@@printed_celltype_list, {})

  #   $root_namespace.print_all_cells

  #   $stdout = STDOUT
  #   log_file.close

  #   trees = process_file("#{$gen}/tecsflow.log")

  #   cell_list = []
  #   name_space_list = $root_namespace.get_namespace_list
    
  #   name_space_list.each do |name_space|
  #     name_space.get_cell_list.each do |cell|
  #       cell_list << cell
  #     end
  #   end

  #   json_obj = []

  #   cell_list.each{ |cell|

  #     next if cell.get_celltype.is_active?

  #     # cellname = cell.get_name.to_s
  #     cellname = cell.get_global_name.to_s
  #     celltype = cell.get_celltype.get_name.to_s

  #     cell_obj = {
  #       "Cell": cellname,
  #       "Celltype": celltype,
  #       "Accessed": []
  #     }

  #     trees.each_with_index do |tree, index|

  #       # その active_cell tree のなかに、cellname があるかどうかを探す
  #       found_nodes = tree.find_nodes_by_cellname(cellname)

  #       # あれば、以下の処理を行う
  #       if found_nodes.any?

  #         # JSONオブジェクトの初期化

  #         found_nodes.each do |node|

  #           path = node.formatted_path_to_root
  #           array = path.split("=>").map(&:strip)

  #           # 最初の要素の処理
  #           first_element = array[0]
  #           first_split = first_element.split("->")
  #           active_cell = first_split[0].strip
  #           callport = first_split[1].strip.split(".")[0]
  #           function = first_split[1].strip.split(".")[1]

  #           # 二番目の要素の処理
  #           second_element = array[1]
  #           second_split = second_element.split("->")
  #           calleeport = second_split[0].strip.split(".")[1]

  #           accessed_celltype = nil
  #           cell_list.each do |c|
  #             if c.get_name.to_s == active_cell then
  #               accessed_celltype = c.get_celltype.get_name.to_s
  #               break
  #             end
  #           end

  #           # 最初の要素の情報をJSONオブジェクトに追加
  #           accessed_item = {
  #             "ActiveCell": active_cell,
  #             "Celltype": accessed_celltype,
  #             "Callport": callport,
  #             "Calleeport": calleeport,
  #             "Function": function,
  #             "Path": []
  #           }

  #           # 二番目以降の要素の処理
  #           (array[1..-1] || []).each_with_index do |element, index|
  #             break if index == array.size - 2
  #             next_split = element.split("->")
  #             cell_name = next_split[0].strip.split(".")[0]
  #             callport = next_split[1].strip.split(".")[0]
  #             function = next_split[1].strip.split(".")[1]
  #             calleeport = if array[index + 2]
  #                            array[index + 2].split("->")[0].strip.split(".")[1]
  #                          else
  #                            ""
  #                          end
              
  #             path_celltype = nil
  #             cell_list.each do |c|
  #               if c.get_name.to_s == cell_name then
  #                 path_celltype = c.get_celltype.get_name.to_s
  #                 break
  #               end
  #             end

  #             path_item = {
  #               "CellName": cell_name,
  #               "Celltype": path_celltype,
  #               "Callport": callport,
  #               "Calleeport": calleeport,
  #               "Function": function
  #             }
  #             accessed_item[:Path] << path_item
            
  #           end
  #           cell_obj[:Accessed] << accessed_item

  #         end
  #       end
  #     end

  #     json_obj.push(cell_obj)
  #   }

  #   json_file = File.open( "#{$gen}/tecsflow.json", "w" ) do |f|
  #     f.write(JSON.pretty_generate(json_obj))
  #   end
  # end

  def self.analyze_deadlock json_list, cell_list

    cell_list_to_s = []
    cell_list.each{ |cell|
      # cell_list_to_s << cell.get_name.to_s
      cell_list_to_s << cell.get_global_name.to_s
    }

    # アクティブセルのリストを取得
    active_cell_list = []
    cell_list.each{ |cell|
      active_cell_list << cell if cell.get_celltype.is_active?
    }

    # アクティブセルの String リストを取得
    active_cell_list_to_s = []
    active_cell_list.each{ |task|
      active_cell_list_to_s << task.get_global_name.to_s
    }

    # すべてのセルに対して、アクティブセル名のキーと、"ExclusiveControl" のキーを作成
    accessed_cell_hash = cell_list_to_s.each_with_object({}) do |cell, h|
      h[cell] = active_cell_list.each_with_object({}) do |task, sub_h|
        sub_h[task.get_global_name.to_s] = false
      end
      h[cell]["ExclusiveControl"] = false
    end

    # JSON のコールフローを解析し、どのアクティブセルからアクセスされるのかを格納
    json_list.each do |entry|
      cell_name = entry[:Cell].to_s
      accessed = entry[:Accessed]

      accessed.each do |task|
        task_name = task[:ActiveCell].to_s
        accessed_cell_hash[cell_name][task_name] = true
      end
    end

    # 排他制御をかけるセルを特定
    cell_list.each do |cell|
      cell.get_celltype.get_port_list.each do |port|
        next if port.get_port_type == :ENTRY

        next if cell.get_join_list.get_item(port.get_name) == nil

        callee_cell_name = cell.get_join_list.get_item(port.get_name).get_cell.get_global_name.to_s

        # 呼び先のセルがアクセスされるアクティブセルの数をカウント
        callee_cell_count = 0
        active_cell_list.each do |task|
          if accessed_cell_hash[callee_cell_name][task.get_global_name.to_s] then
            callee_cell_count += 1
          end
        end

        # 呼び元と呼び先が同じアクセスされるアクティブセルを持っているかどうかを判定
        same_accessed = true
        # current_cell_hash = accessed_cell_hash[cell.get_name.to_s].dup
        current_cell_hash = accessed_cell_hash[cell.get_global_name.to_s].dup
        current_cell_hash.delete("ExclusiveControl")
        callee_cell_hash = accessed_cell_hash[callee_cell_name].dup
        callee_cell_hash.delete("ExclusiveControl")
        same_accessed = false if current_cell_hash != callee_cell_hash

        # 呼び先のセルがアクセスされるアクティブセルの数が 2 以上で、かつ呼び元と呼び先が同じアクセスされるアクティブセルを持っていない場合、排他制御をかける
        if same_accessed == false && callee_cell_count >= 2 then
          accessed_cell_hash[callee_cell_name]["ExclusiveControl"] = true
        end
      end
    end

    # puts "accessed_cell_hash: #{accessed_cell_hash}"

    # 排他制御がかかっているセルのみを抽出
    exclusive_control_cells = accessed_cell_hash.select{ |k, v| v["ExclusiveControl"] == true }

    # 排他制御が必要なセルの情報を json_list に反映
    json_list.each do |entry|
      next if exclusive_control_cells[entry[:Cell].to_s] == nil
      entry[:ExclusiveControl] = "true"
    end

    # 以下はサイクルデッドロックの検知コードだったが、サイクルデッドロックは TECS/Rust では発生しないためコメントアウト
    # cycle_deadlock_detection json_list, exclusive_control_cells, active_cell_list

    # 再入サイクルの検知
    puts "--- reentry cycles ---"
    # puts "#{$reentry_cell_list}"

    $reentry_cell_list.each_with_index do |(reentered_cell, reentry_cell), index| 
      # puts "#{reentry_cell} -> #{reentered_cell}"
      if accessed_cell_hash[reentered_cell]["ExclusiveControl"] == true then
        print "[re-entry #{index + 1}] ::"

        accessed_cell_hash[reentry_cell].each_with_index do |(k, v), i|
          next if k == "ExclusiveControl"
          print ", " if i > 0
          
          if v then
            print "#{k}"
          end
        end
        print "\n"

        puts "\t#{reentered_cell} is under exclusive control and will be re-entered on a call from #{reentry_cell}"

      end
    end

  end

  def self.cycle_deadlock_detection json_list, exclusive_list, active_cell_list
    graph = Graph.new

    # exclusive_list.each do |cell_k, task_v|
    #   task_v.each do |tsk_k, tsk_v|
    #     next if tsk_k == "ExclusiveControl"
    #     graph.add_edge(cell_k, tsk_k) if tsk_v
    #   end
    # end

    exclusive_list.each do |cell_name, activetask_v|
      json_list.each do |entry|
        #TODO: 同じ名前のセルが存在する場合、正しいセルかどうかを判定する機能を実装する必要がある
        next if entry[:Cell].to_s != cell_name.to_s
        entry[:Accessed].each do |task|
          current_cell_name = task[:ActiveCell].to_s
          task[:Path].each do |path|
            next if exclusive_list[path[:CellName].to_s] == nil
            graph.add_edge(current_cell_name, path[:CellName].to_s)
            current_cell_name = path[:CellName].to_s
          end
          graph.add_edge(current_cell_name, cell_name)
        end
      end
    end

    cycles = graph.detect_cycles

    # puts "#{accessed_cell_hash}"

    puts "--- cycle deadlocks ---"
    if cycles.empty?
    else
      cycles.each_with_index do |cycle, index|
        tasks = []
        resources = []

        cycle.each do |cell|
          if active_cell_list_to_s.include?(cell)
            tasks << cell
          else
            resources << cell
          end
        end

        tasks.uniq!
        resources.uniq!

        puts "[cycle #{index + 1}] ::#{tasks.join(', ')}"
        puts "\t#{tasks[0]} -> (#{resources.join(', ')}) <- #{tasks[-1]}"
      end
    end
  end

  def self.process_file(file)

    trees = []
    current_lines = []
  
    File.foreach(file) do |line|
      next if line.strip.empty? || !line.strip.start_with?("[active cell]") && current_lines.empty?
      if line.strip.start_with?("[active cell]")
        trees << create_tree_from_lines(current_lines) unless current_lines.empty?
        current_lines = [line.strip.split("::").last.strip]
      else
        current_lines << line
      end
    end
  
    trees << create_tree_from_lines(current_lines) unless current_lines.empty?
    trees
  end

  # def self.create_tree_from_lines(lines)
  #   root = nil
  #   current_node = nil
  #   node_stack = []
  
  #   lines.each_with_index do |line, index|
  #     indent_level = line.match(/^\s*/)[0].size
  #     node_value = index.zero? ? line.strip.split(' ').first : line.strip
  #     node = FlowTreeNode.new(node_value)
  
  #     if indent_level == 0
  #       root = node
  #       current_node = root
  #       node_stack = [[current_node, indent_level]]
  #     else
  #       while node_stack.any? && node_stack.last[1] >= indent_level
  #         node_stack.pop
  #       end
  #       parent_node, _ = node_stack.last
  #       parent_node.add_child(node) if parent_node
  #       current_node = node
  #       node_stack.push([current_node, indent_level])
  #     end
  #   end
  
  #   root
  # end

  require 'set'

  class Graph
    def initialize
      @adj_list = {}
    end
  
    def add_edge(v1, v2)
      @adj_list[v1] ||= []
      @adj_list[v2] ||= []
      @adj_list[v1] << v2
      @adj_list[v2] << v1
    end
  
    def detect_cycles
      visited = {}
      cycles = []
  
      @adj_list.keys.each do |v|
        visited[v] = false
      end
  
      @adj_list.keys.each do |v|
        next if visited[v]
        detect_cycle_dfs(v, v, visited, [], cycles)
      end
  
      filtered_cycles = unique_cycles(cycles)
      filtered_cycles.select { |cycle| cycle.length < 7 } # 長さが6以上のサイクルを除外
    end
  
    private
  
    def detect_cycle_dfs(start, v, visited, path, cycles)
      visited[v] = true
      path << v
  
      @adj_list[v].each do |neighbor|
        if !visited[neighbor]
          detect_cycle_dfs(start, neighbor, visited, path.dup, cycles)
        elsif neighbor == start && path.length > 2
          cycle = (path + [neighbor])
          cycles << cycle unless contains_same_cycle?(cycles, cycle)
        end
      end
  
      visited[v] = false
    end
  
    def contains_same_cycle?(cycles, new_cycle)
      normalized_new_cycle = new_cycle.map { |v| v }.sort
      cycles.any? { |cycle| cycle.map { |v| v }.sort == normalized_new_cycle }
    end
  
    def unique_cycles(cycles)
      seen_sets = Set.new
      unique = []
  
      cycles.each do |cycle|
        cycle_set = cycle.to_set
        unless seen_sets.include?(cycle_set)
          seen_sets.add(cycle_set)
          unique << cycle
        end
      end
  
      unique
    end
  end
  
  

end



TECSFlow.main
