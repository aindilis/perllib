#!/usr/bin/perl -w

use Data::Dumper;
use URI::Escape qw(uri_escape_utf8);

my $it = "'";

print Dumper(uri_escape_utf8('%'));
