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

@@rustflow = false
@@rustflow_option = nil

require "#{$tecsflow_base_path}/flowlib/classes.rb"
require "#{$tecsflow_base_path}/tecslib/version.rb"
require "#{$tecsflow_base_path}/tecsgen.rb"

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
        @@rustflow = true
        @@rustflow_option = "only"
      elsif option == "both" then
        @@rustflow = true
        @@rustflow_option = "both"
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
    input_string.gsub(/(.)([A-Z])/, '\\1_\\2').downcase
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
if @@rustflow then
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

  #=== print_all_cells
  # print all call flow beginning with active cell's call port function
  def print_all_cells
    # for each active cell
    # print @cell_list
  	@cell_list.each{|cell|
      # print "cell: #{cell.get_name}\n"
 			celltype = cell.get_celltype
 			call_funcs = {}
  		if celltype.is_active? then
  			if ! celltype.kind_of? CompositeCelltype then
		  		print "[active cell] #{cell.get_namespace_path}"
          print_locale cell.get_locale
          print "\n"
		  		cell.get_join_list.get_items.each{ |j|
		  			if j.get_definition.kind_of? Port then
		  				port = j.get_definition
			  			port.get_signature.get_function_head_array.each{ |f|
			  			  func_name = "->#{port.get_name}.#{f.get_name}__T".to_sym
                # print "func_name: #{func_name}\n"
                # if @@rustflow then
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
                if @@rustflow then
                  ep_func = "#{camel_case(snake_case(ep.get_name.to_s))}For#{get_rust_celltype_name(celltype)}.#{f.get_name}".to_sym
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
          # print "  ", ep_func, "\n"
          if $tcflow_funclist[ ep_func ].kind_of? TCFlow::Function then
            func = $tcflow_funclist[ ep_func ]
            if ! func.is_printed? then
              #if cell_printed == false then
              #  cell_printed = true
              # if cell.get_namespace_path == nil then
              #   cell.show_tree 0
              # end
                print "[unreferenced entry function] #{cell.get_namespace_path}.#{entry_port_name}.#{func_name}"
              #end
              cell.print_entry_func_flow entry_port_name, func_name, indent_level, parent_cell
            end
          end
        }
      }
    }
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

  def print_entry_func_flow entry_port_name, func_name, indent_level, parent_cell
    func_nsp = get_function_nsp entry_port_name, func_name, parent_cell
    # print "\nentry:", func_nsp, "\n"
    @@printed_cell_list[ self ] = true
    if @@printed_func_nsp_list[ func_nsp ] then
      # print "\n"
      # print_indent indent_level
      # print func_nsp
      print ": printed\n"
      return
    end
    @@printed_func_nsp_list[ func_nsp ] = true
    if ! @celltype.kind_of? CompositeCelltype
      ep_func = "#{@celltype.get_global_name}_#{entry_port_name}_#{func_name}".to_sym
      if @@rustflow then
        ep_func = "#{camel_case(snake_case(entry_port_name.to_s))}For#{get_rust_celltype_name(@celltype)}.#{func_name}".to_sym
        # print "print_entry_func_flow: rustflow is true\n"
      end
      if $tcflow_funclist[ ep_func ] then
        function = $tcflow_funclist[ ep_func ]
        print_locale function.get_locale
        print "\n"
        function.set_printed
        function.get_call_funcs.each{ |call_func_name, func|
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
    j = join
    if j != nil then
      if ! $unopt then
        callee_cell = j.get_rhs_cell
        # print "callee_cell = ", callee_cell, "\n"
        callee_port = j.get_rhs_port.get_name
        # print "callee_port = ", callee_port, "\n"
        callee_subsc = j.get_rhs_subscript
        # print "callee_subsc = ", callee_subsc, "\n"
      else
        callee_cell = j.get_rhs_cell1
        # print "callee_cell = ", callee_cell, "\n"
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
    indent_level = print_indent indent_level
    no_cell_name = no_caller_cell
    if @@rustflow then
      rust_call_port_name = "#{snake_case(call_port_name.to_s)}".to_sym
      print_rust_name no_cell_name, rust_call_port_name, call_subsc, func_name
    else
      print_name no_cell_name, call_port_name, call_subsc, func_name
    end
    print " => "
    no_cell_name = false
    if @@rustflow then
      rust_entry_port_structure = "#{camel_case(snake_case(entry_port_name.to_s))}For#{get_rust_celltype_name(callee_cell.get_celltype)}".to_sym
      callee_cell.print_rust_name no_cell_name, rust_entry_port_structure, callee_subsc, func_name
    else
      callee_cell.print_name no_cell_name, entry_port_name, callee_subsc, func_name
    end

    if @@rustflow_option == "both" then
      print "\n"
      indent_level = print_indent indent_level
      no_cell_name = no_caller_cell
      print_name no_cell_name, call_port_name, call_subsc, func_name
      print " => "
      no_cell_name = false
      callee_cell.print_name no_cell_name, entry_port_name, callee_subsc, func_name
    end
  end
end

module TECSFlow
  include Locale_printer
  require 'json'
  def self.main
    doing = "nothing"
    log_file = File.open( "#{$gen}/tecsflow.log", "w" )
    $stdout = log_file
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
    rescue
      print "fatal: fail to load '#{$tcflow_dump_file_name}' in #{doing}\n"
      exit 1
    end
    Namespace.set_root $root_namespace
    $root_namespace.print_all_cells
    print_unref_function

    $stdout = STDOUT
    log_file.close
    print_file = File.read( "#{$gen}/tecsflow.log" )
    print print_file

    generate_json_file
    
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

  def self.generate_json_file 
    log_file = File.read( "#{$gen}/tecsflow.log" )

    data = []
    call_flow_data = []

    cell_list = $root_namespace.get_cell_list
    cell_list.each{ |cell|
      print "cell: #{cell.get_name}\n"
      print "celltype: #{cell.get_celltype.get_name}\n"
    }

    json_file = File.open( "#{$gen}/tecsflow.json", "w" )
    json_file.close
  end

end

TECSFlow.main
