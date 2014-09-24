use strict;
use warnings;
use Test::More;

use File::Basename;
use FFI::Raw;

my $lib = join '/', dirname(__FILE__), 'rust-code';
system("rustc --crate-type dylib --opt-level 3 -o $lib.so $lib.rs")
    and die "Aborting due to build failure\n";

my $chars_by_count = FFI::Raw->new(
    "$lib.so", 'chars_by_count',
    FFI::Raw::str,
    FFI::Raw::str,
);

is $chars_by_count->("aabcdacbba"), "abcd", 'correct output';
is $chars_by_count->(""), "", 'correct output for empty string';

done_testing;
