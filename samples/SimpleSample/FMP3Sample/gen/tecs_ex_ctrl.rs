use itron::mutex::{MutexRef, LockError, UnlockError};
use itron::semaphore::{SemaphoreRef, WaitError, SignalError};
use crate::print;
use crate::tecs_print::*;
use itron::abi::uint_t;

pub trait LockManager {
    fn lock(&self);
    fn unlock(&self);
}

pub type TECSDummyLockGuard = u32;

pub struct TECSDummyExCtrlRef{}

pub struct TECSMutexRef<'a>{
	pub inner: MutexRef<'a>,
}

pub struct TECSSemaphoreRef<'a>{
	pub inner: SemaphoreRef<'a>,
}

#[link_section = ".rodata"]
pub static DUMMY_LOCK_GUARD: TECSDummyLockGuard = 0;

#[link_section = ".rodata"]
pub static DUMMY_EX_CTRL_REF: TECSDummyExCtrlRef = TECSDummyExCtrlRef{};

impl LockManager for TECSDummyExCtrlRef{
    #[inline]
    fn lock(&self){}
    #[inline]
    fn unlock(&self){}
}

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
                    BadSequence => {
                        print!("BadContextError::BadSequence", );
                        loop{}
                    },
                }
            },
        }
    }
}

impl LockManager for TECSSemaphoreRef<'_>{
    #[inline]
    fn lock(&self){
        match self.inner.wait(){
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
        match self.inner.signal(){
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
