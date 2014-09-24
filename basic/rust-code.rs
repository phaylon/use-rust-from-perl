
extern crate libc;

use libc::{ c_long };

#[no_mangle]
pub extern "C"
fn add_numbers(n: c_long, m: c_long) -> c_long {
    n + m
}

