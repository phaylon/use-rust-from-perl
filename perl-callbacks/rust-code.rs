
#[no_mangle]
pub extern "C"
fn sum_mapped_range(start: int, end: int, cb: extern fn(int) -> int) -> int {
    range(start, end)
        .map(|n| cb(n))
        .fold(0i, |a, n| a + n)
}
