
// A simple struct as example.
pub struct Rectangle {
    width: uint,
    height: uint,
}

// Our type can have methods
impl Rectangle {
    pub fn area(&self) -> uint { self.width * self.height }
}

#[no_mangle]
pub unsafe extern "C"
fn make_rectangle(width: uint, height: uint) -> Box<Rectangle> {

    // We return a box to a rectangle. This will allocate space
    // for our rectangle on the heap. The box itself is just
    // a pointer so that's what we'll treat it as on the Perl
    // side.
    //
    // Since we're returning the box, Perl will own this data
    // and is responsible for dropping it.
    box Rectangle {
        width: width,
        height: height,
    }
}

#[no_mangle]
pub unsafe extern "C"
fn get_rectangle_area(rectangle: &Rectangle) -> uint {

    // We take our pointer as argument, but this time we'll
    // take it as a borrow. Since it doesn't belong to us,
    // Rust won't drop it at the end of the scope.
    rectangle.area()
}

#[no_mangle]
pub unsafe extern "C"
fn drop_rectangle(_rectangle: Box<Rectangle>) {
    // Here we take the rectangle as a box again. This means
    // we take ownership of it and destroy it.
}
