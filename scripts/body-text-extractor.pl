#!/usr/bin/perl -w

use PerlLib::BodyTextExtractor;
use PerlLib::Cacher;

use Data::Dumper;

my $cacher = PerlLib::Cacher->new;
$cacher->get($ARGV[0]);
print BodyTextExtractor
  (HTML => $cacher->content);
