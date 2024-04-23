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

def parse_rust_functions(rust_file)

  brace_count = 0
  # signature_impl_flag = 0

  signature_impl_pattern = /impl\s+S\w*\s+for\s+E\w*ForT\w*/
  fn_pattern = /fn\s+\w+\s*\(.*?\)\s*/
  callport_function_pattern = /c_\w+\.\w+/

  rust_file_lines = File.readlines(rust_file, chomp: true)

  # print "1: #{rust_file_lines[0]}\n"

  rust_file_lines.each do |line|

    open_braces = line.scan(/{/)
    close_braces = line.scan(/}/)
    brace_count += open_braces.length - close_braces.length

    if line =~ signature_impl_pattern && brace_count == 1
      signature_impl = line.scan(signature_impl_pattern)
      print "#{signature_impl}\n"
    end

    if line =~ fn_pattern && brace_count == 2
      function_name = line.scan(/fn\s+\w+\s*\(.*?\)\s*/)
      print "\t[#{function_name}]\n"
    end

    if brace_count >= 2
      c_calls = line.scan(callport_function_pattern)
      c_calls.each do |call|
        print "\t\t#{call}\n"
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

        # print "f = #{f}\n"

        parse_rust_functions(f)


        # # Regular expression to find function definitions starting with "fn"
        # fn_blocks_regex = /fn\s+\w+\s*\(.*?\)\s*\{.*?\}/m
        
        # # Regular expression to find "c_*.function_name" patterns
        # c_call_regex = /c_\w+\.\w+/

        # # Collect all the fn blocks
        # fn_blocks = rust_file.scan(fn_blocks_regex)

        # # Process each fn block
        # fn_blocks.each do |fn_block|
        #   fn_name = fn_block.scan(/fn\s+\w+\s*\(.*?\)\s*/)
        #   print "#{fn_name}\n"
        #   # Collect all the calls to "c_*" objects
        #   c_calls = fn_block.scan(c_call_regex)
        #   # Print each call found in the current fn block
        #   c_calls.each do |call|
        #     print "#{call}\n"
        #   end
        # end
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


