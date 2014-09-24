use strict;
use warnings;
use Test::More;

use File::Basename;
use FFI::Raw;

my $lib = join '/', dirname(__FILE__), 'rust-code';
system("rustc --crate-type dylib --opt-level 3 -o $lib.so $lib.rs")
    and die "Aborting due to build failure\n";

my $add = FFI::Raw->new(
    "$lib.so", 'add_numbers',
    FFI::Raw::long,
    FFI::Raw::long, FFI::Raw::long,
);

is $add->(23, 42), 65, 'numbers added';

done_testing;
