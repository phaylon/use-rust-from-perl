
extern crate libc;
extern crate native;

use libc::{ c_char };
use std::c_str::{ CString };
use std::collections::{ HashMap };

fn process_string(text: &str) -> String {

    // Create a HashMap to collect character counts into
    let mut map = HashMap::new();

    // Increase count in HashMap for each character
    for c in text.chars() {
        map.insert_or_update_with(c, 1u, |_, v| *v += 1);
    }

    // Collect the keys in a Vec so we can sort them
    let mut keys = map.keys().map(|k| *k).collect::<Vec<char>>();

    // Sort by occurrence as tracked in the HashMap
    keys.sort_by(|a, b| map[*b].cmp(&map[*a]));
    
    // Return new String with ordered charrs
    String::from_chars(keys.as_slice())
}

#[no_mangle]
pub unsafe extern "C"
fn chars_by_count(inp: *const c_char) -> *const c_char {

    // This is where we'll store the pointer for the output string
    let mut ptr = 0 as *const c_char;

    // We're using features requiring the runtime (HashMap/TaskRng), so we'll run
    // our transform in an isolated task
    let task = native::task::new((0, std::uint::MAX));
    task.run(|| {

        // Wrap the C string pointer in something we can handle.
        // We can't own the pointer, or there will be a segfault
        // (I assume FFI::Raw wants to keep owning it).
        let inp_cstring = CString::new(inp, false);

        // Calculate our sorted string into another C string
        let out_cstring = process_string(inp_cstring.as_str().unwrap()).to_c_str();

        // Get the pointer for our result string
        ptr = out_cstring.unwrap();

    }).drop();

    // Return the pointer to the string
    ptr
}
