#!/usr/bin/perl -w

use PerlLib::FileType;

my $type = PerlLib::FileType->new();

$type->FileType
  (File => $ARGV[0]);
