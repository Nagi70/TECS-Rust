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
            file.print "use crate::kernel_cfg::*;  //特別な生成部\n"
            # file.print "use crate::kernel_obj_ref::*;  //特別な生成部\n"
            file.print "use itron::abi::*;  //特別な生成部\n"
            # TODO: task の部分の変換
            file.print "use itron::task::#{obj_ref_str};  //特別な生成部\n"
            file.print "use core::num::NonZeroI32;  //特別な生成部\n"
        end
        super(file)
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
                file.print "\tpub #{attr.get_name.to_s}: "
                # file.print "#{c_type_to_rust_type(attr.get_type)}"
                str = c_type_to_rust_type(attr.get_type)
                # 属性や変数のフィールドに構造体がある場合は，ライフタイムを付与する必要がある
                # itron-rsオブジェクトに対する，特別な生成
                if str == "TaskRef" then
                    # ライフタイムを付与
                    str = "TaskRef<'a>"
                    file.print "#{str},  //特別な生成部\n"
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

    # tecs_mutex.rs を生成する
    def gen_tecs_mutex_rs
        if File.exist?("#{$gen}/tecs_mutex.rs") == false then
            contents = <<~'EOS'
use itron::mutex::{MutexRef, LockError, UnlockError};
use crate::print;
use crate::print::*;


pub trait LockableForMutex {
    fn lock(&self);
    fn unlock(&self);
}

pub struct TECSMutexRef<'a>{
	pub inner: MutexRef<'a>, //MutexRef
}

pub struct TECSDummyMutexRef{
}

impl LockableForMutex for TECSMutexRef<'_>{
    fn lock(&self){
        match self.inner.lock(){
            Ok(_) => {
            },
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
    fn unlock(&self){
        match self.inner.unlock(){
            Ok(_) => {
            },
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
    fn lock(&self){
    }
    fn unlock(&self){
    }
}

pub static DUMMY_MUTEX_REF: TECSDummyMutexRef = TECSDummyMutexRef{
};
            EOS

            mutex_file = CFile.open( "#{$gen}/tecs_mutex.rs", "w" )
            mutex_file.print contents
            mutex_file.close

        end
    end

    # syslog の Rust ラップである print.rs を生成する
    def gen_tecs_print_rs
        if File.exist?("#{$gen}/tecs_print.rs") == false then
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
