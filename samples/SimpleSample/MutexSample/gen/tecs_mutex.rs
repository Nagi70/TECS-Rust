use itron::mutex::{MutexRef, LockError, UnlockError};
use crate::print;
use crate::print::*;

pub type TECSDummyMutexGuard = i32;

pub trait LockableForMutex {
    fn lock(&self);
    fn unlock(&self);
}

pub struct TECSMutexRef<'a>{
	pub inner: MutexRef<'a>, //MutexRef
}

pub struct TECSDummyMutexRef{
}

pub static DUMMY_MUTEX_GUARD: TECSDummyMutexGuard = 0;

impl LockableForMutex for TECSMutexRef<'_>{
    #[inline]
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
    #[inline]
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
    #[inline]
    fn lock(&self){
    }
    #[inline]
    fn unlock(&self){
    }
}

pub static DUMMY_MUTEX_REF: TECSDummyMutexRef = TECSDummyMutexRef{
};
