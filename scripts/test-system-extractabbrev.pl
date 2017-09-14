#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::ExtractAbbrev;

my $abbrev = System::ExtractAbbrev->new();

my $contents = read_file($ARGV[0]);
print Dumper
  ($abbrev->ExtractAbbrev
   (
    Text => $contents,
   ));
