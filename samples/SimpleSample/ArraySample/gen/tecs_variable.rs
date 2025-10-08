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
