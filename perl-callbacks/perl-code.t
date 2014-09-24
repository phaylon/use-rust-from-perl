use strict;
use warnings;
use Test::More;

use File::Basename;
use FFI::Raw;

my $lib = join '/', dirname(__FILE__), 'rust-code';
system("rustc --crate-type dylib --opt-level 3 -o $lib.so $lib.rs")
    and die "Aborting due to build failure\n";

# The callback is passed as a pointer
my $sum_mapped_range = FFI::Raw->new(
    "$lib.so", 'sum_mapped_range',
    FFI::Raw::int,
    FFI::Raw::int, FFI::Raw::int, FFI::Raw::ptr,
);

my $count = 0;

# Construct our callback
my $cb = FFI::Raw::callback(sub { $count++; 2 * shift }, FFI::Raw::int, FFI::Raw::int);

is $sum_mapped_range->(1, 101, $cb), 10_100, 'correct result';
is $count, 100, 'callback was invoked 100 times';

done_testing;
