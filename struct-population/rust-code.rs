
#[repr(C)]
pub struct MinMaxResult {
    min: int,
    max: int,
}

#[no_mangle]
pub extern "C"
fn find_min_max(res: &mut MinMaxResult, nums: &[int, ..10]) {
    for n in nums.iter() {
        if res.min > *n { res.min = *n }
        if res.max < *n { res.max = *n }
    }
}

