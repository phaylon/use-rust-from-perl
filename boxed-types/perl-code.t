use strict;
use warnings;
use Test::More;

use File::Basename;
use FFI::Raw;

my $lib = join '/', dirname(__FILE__), 'rust-code';
system("rustc --crate-type dylib --opt-level 3 -o $lib.so $lib.rs")
    and die "Aborting due to build failure\n";

our $was_dropped;

my $drop_rectangle = FFI::Raw->new(
    "$lib.so", 'drop_rectangle',
    FFI::Raw::void, FFI::Raw::ptr,
);

my $make_rectangle = FFI::Raw->new(
    "$lib.so", 'make_rectangle',
    FFI::Raw::ptr, FFI::Raw::uint, FFI::Raw::uint,
);

my $get_rectangle_area = FFI::Raw->new(
    "$lib.so", 'get_rectangle_area',
    FFI::Raw::uint, FFI::Raw::ptr,
);

# Since we take ownership of the object, we'll have use a
# class to wrap the pointer, so we can drop it once our
# wrapper is no longer used. It will also make it easier to
# access methods.
do {
    package Rectangle;

    # Construct the wrapper by receiving a pointer and storing it.
    sub new {
        my ($class, $width, $height) = @_;
        return bless {
            pointer => $make_rectangle->($width, $height),
        }, $class;
    }

    # This method will call the extern function of the Rust code,
    # which will in turn run the method on the object.
    sub area {
        my ($self) = @_;
        return $get_rectangle_area->($self->{pointer});
    }

    # Once the wrapper is no longer used, we have to drop the
    # data we're pointing to.
    sub DESTROY {
        my ($self) = @_;
        $drop_rectangle->($self->{pointer});
        $was_dropped++;
    }
};

$was_dropped = 0;
do {
    my $rect = Rectangle->new(30, 30);
    isa_ok $rect, 'Rectangle', 'rectangle object';
    is $rect->area(), 900, 'rectangle area';
};
is $was_dropped, 1, 'rectangle was dropped';

done_testing;
