use strict;
use warnings;
use Test::More;

use File::Basename;
use FFI::Raw;
use FFI::Raw::MemPtr;

my $lib = join '/', dirname(__FILE__), 'rust-code';
system("rustc --crate-type dylib --opt-level 3 -o $lib.so $lib.rs")
    and die "Aborting due to build failure\n";

# The callback is passed as a pointer
my $sum_mapped_range = FFI::Raw->new(
    "$lib.so", 'find_min_max',
    FFI::Raw::void,
    FFI::Raw::ptr, FFI::Raw::ptr,
);

# Pack together the initial data for the struct
my $result_init = pack 'ii', 0, 0;

# Allocate the struct and store the initial values
my $result_ptr = FFI::Raw::MemPtr
    ->new_from_buf($result_init, length $result_init);

# Build our set of values
my $values_init = pack 'i' x 10, (23, -42, 109, -33, 77, -13, 36, -59, 82, 0);
my $values_ptr = FFI::Raw::MemPtr
    ->new_from_buf($values_init, length $values_init);

# Run the Rust calculation function
$sum_mapped_range->($result_ptr, $values_ptr);

# Extract values from the result struct
my ($min, $max) = unpack 'ii', $result_ptr->tostr(length $values_init);

is $min, -59, 'min value';
is $max, 109, 'max value';

done_testing;
