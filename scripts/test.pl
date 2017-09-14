#!/usr/bin/perl -w

use Data::Dump qw(dump);
use Data::Dumper;

my $function = "test";
my $sub = eval "sub {$function(\@_)}";

sub test {
  print Dumper(@_);
}

$sub->({Hello => 1});

