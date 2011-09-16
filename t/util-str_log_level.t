#!perl

use 5.010;
use strict;
use warnings;
use Test::More 0.96;

use Sub::Spec::Util qw(str_log_level);

ok(!str_log_level("x"), "unknown string = undef");
ok(!str_log_level(7), "unknown int = undef");
is(str_log_level(6), "trace", "int");
is(str_log_level("debug"), "debug", "str");

done_testing();

