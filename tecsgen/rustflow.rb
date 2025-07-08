#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
#  TCFlow
#     Clanguage flow analyzer
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
#   $Id: bnf.y.rb 2850 2018-04-01 12:38:45Z okuma-top $
#++

require 'optparse'
require_relative "flowlib/classes.rb"

$exe_name="rustflow"
$version="V1.0.0.0"
$cpp_cmd=nil
$b_version=false
$b_summarize = false
$b_list = false
$gen_dir = "gen"
$read_dump = false
$b_print_all_token = false

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

def parse_rust_functions(rust_file)

  brace_count = 0

  signature_impl_pattern = /impl\s+S\w*\s+for\s+E\w*ForT\w*/
  fn_pattern = /fn\s+\w+\s*\(.*?\)\s*/
  # callport_function_pattern = /c_\w+\.\w+/
  callport_function_pattern = /lg\.c_\w+\.\w+/

  rust_file_lines = File.readlines(rust_file, chomp: true)

  @current_signature_impl = nil
  @current_function_name = nil
  @current_entry_function = nil
  @currennt_entry_structure = nil

  rust_file_lines.each do |line|

    open_braces = line.scan(/{/)
    close_braces = line.scan(/}/)
    brace_count += open_braces.length - close_braces.length


    # impl Sxxx for EyyyForTzzz の検知
    # TECSジェネレータが生成した impl 内の実装だけを確認するため
    if line =~ signature_impl_pattern && brace_count == 1
      @curennt_signature_impl = line.scan(signature_impl_pattern)
      # print "#{@curennt_signature_impl}\n"
      @currennt_entry_structure = @curennt_signature_impl[0].scan(/E\w*ForT\w*/)
      # print "currennt_entry_structure: #{@currennt_entry_structure}\n"
    end

    # fn xxx() の検知
    # impl 内の関数実装だけを確認するため
    if line =~ fn_pattern && brace_count == 2
      @current_function_name = line.scan(/fn\s+\w+\s*\(.*?\)\s*/)
      # print "\t[#{@current_function_name}]\n"
      temp = @current_function_name[0]
      current_func_name_without_arguments = temp[/fn (\w+)/, 1]
      # current_tecs_celltype_name = nil
      # current_tecs_entryport_name = nil
      # funclist に格納する関数名の生成 (旧バージョン)
      entry_func_name = "#{@currennt_entry_structure[0]}.#{current_func_name_without_arguments}"
      # funclist に格納する関数名の生成 (新バージョン)
      # entry_func_name = "#{@current_tecs_celltype_name}_#{@current_tecs_entryport_name}_#{current_func_name_without_arguments}"
      # print "\t\t#{entry_func_name}\n"
      @current_entry_function = nil
      @current_entry_function = TCFlow::Function.new(["#{rust_file}", rust_file_lines.index(line)+1])
      @current_entry_function.set_name(entry_func_name)
      # print "debug: #{entry_func_name} = #{@current_entry_function}\n"
      # entry_func = nil
    end

    # print "debug: #{@current_entry_function}\n"

    # 受け口関数内で，呼び口関数が呼ばれているかを検知
    if brace_count >= 2
      c_calls = line.scan(callport_function_pattern)
      c_calls.each do |call|
        # 旧バージョン
        # before_dot = call.split('.').first
        # after_dot = call.split('.').last
        # cname = before_dot.split("_", 2).last
        # call = "c" + camel_case(cname) + "." + after_dot

        # 新バージョン
        parts = call.split(".")
        lockguard_name = parts[0]
        call_port_name = parts[1]
        function_name = parts[2]

        cname = call_port_name.split("_", 2).last
        call = "c" + camel_case(cname) + "." + function_name
        # call = camel_case(call_port_name) + "." + function_name

        call.prepend("->")
        call << "__T"
        # print "\t\t#{call}\n"
        # call_func_name = TCFlow::Function.new(rust_file_lines.index(line))
        # call_func_name.set_name(call)
        # call_func_name = nil
        # print "debug: #{entry_func}\n"
        if @current_entry_function != nil
          # print "debug: call ref_func\n"
          # @current_entry_function.call_func.push(call.to_sym)
          @current_entry_function.ref_func(call.to_sym)
        end
      end
    end
  end
end

###$debug = true
begin

  ARGV.options {|parser|
    parser.banner = "Usage: tcflow [options] files"
    parser.on('-c', '--cpp=cpp_cmd', 'C pre-processor command, if not specified cpp not invoked,  ex) "-cpp_cmd=cl /E -I include_path"' ){
      |arg|
      $cpp_cmd = arg
    }
    parser.on('-l', '--list', 'list all functions') {
      $b_list = true
    }
    parser.on('-s', '--summarize', 'summarize for top functions') {
      $b_summarize = true
    }
    parser.on( "-g", "--gen=dir", "generate dir"){ |arg|
      $gen_dir = arg
    }
    parser.on( "-r", "--read-rbdmp", "read ruby dump"){
      $read_dump = true
    }
    parser.on( "-t", "--print-all-token", "print all token"){
      $b_print_all_token = true
    }
    parser.version = "#{$version}"
    parser.release = nil
    parser.parse!
  }
  if ARGV.empty? && $read_dump == false
    ARGV.options{|parser|
      puts "#{$exe_name} : #{$version}"
      puts parser.help
      exit 1
    }
  end

  if $read_dump then
    TCFlow::Function.load_funclist "#{$gen_dir}/tcflow.rbdmp"
  else
    require_relative "flowlib/C_parser.tab.rb"
    STDERR.puts "#{$exe_name} : #{$version}"
    ARGV.each{ |file|

      print "Reading: #{file}\n"

      if /\@(.*)/ =~ file
        file_list = []
        begin
          File.open( $1, "r:ASCII-8BIT" ).each{ |f|
            if /^\s*#/ =~ f
              next
            end
            f.strip!
            if f != ""
              file_list << f
            end
         }
        rescue
          STDERR.print "faile to open #{file}"
          exit 1
        end
      else
        file_list = [ file ]
      end

      file_list.each{ |f|

        parse_rust_functions(f)
      
      }
    }

    TCFlow::Function.dump_funclist "#{$gen_dir}/rustflow.rbdmp"
  end

rescue Exception => evar
  # "stack level too deep" が exerb 版では、表示されなかった。非 exerb 版を利用すべし。
  STDERR.print "fatal error: " + evar.to_s + "\n"
  # "stack level too deep" の場合、大量に表示されるので、コメントアウトしてある
  # p $@
# ensure
  # $file.close
end


