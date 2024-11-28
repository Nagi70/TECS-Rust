use itron::semaphore::{SemaphoreRef, WaitError, SignalError};
use crate::print;
use crate::tecs_print::*;
use itron::abi::uint_t;
use crate::tecs_exclusive_control::*;

pub trait LockManager {
    fn lock(&self);
    fn unlock(&self);
}

pub type TECSDummyLockGuard = u32;

pub struct TECSMutexRef<'a>{
	pub inner: SemaphoreRef<'a>,
}

pub struct TECSDummyMutexRef{}

#[link_section = ".rodata"]
pub static DUMMY_LOCK_GUARD: TECSDummyLockGuard = 0;

#[link_section = ".rodata"]
pub static DUMMY_MUTEX_REF: TECSDummyMutexRef = TECSDummyMutexRef{};

impl LockManager for TECSMutexRef<'_>{
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
                    QueueOverflow => {
                        print!("BadContextError::QueueOverflow", );
                        loop{}
                    },
                }
            },
        }
    }
}
