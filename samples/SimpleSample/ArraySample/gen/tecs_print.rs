use itron::abi::*;

extern "C"{
    pub fn syslog_wri_log(prio: u32, p_syslog: *const Syslog) -> ER;
}

pub type Intprt = u32;
pub type HrtCnt = u32;
pub type Id = i32;

#[repr(C)]
pub struct Syslog {
    pub logtype: u32,
    pub logtim: HrtCnt,
    pub prcid: Id,
    pub loginfo: [Intprt; TMAX_LONINFO],
}

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
            let mut ary : [Intprt; 6] = [0; 6];

            ary[0] = concat!($fmt, '\0').as_bytes().as_ptr() as Intprt;

            let mut _index = 1;
            $(
                {
                    ary[_index] = $arg as Intprt;
                    _index = _index + 1;
                }
            )*
            ary
        } ; 

        let mut _syslog = Syslog {
            logtype : LOG_TYPE_COMMENT,
            logtim : 0,
            prcid : 0,
            loginfo : ini_ary
        };

        unsafe{
            let _ = syslog_wri_log(LOG_NOTICE, &_syslog);
        }
    };
}
