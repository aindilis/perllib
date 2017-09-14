#!/usr/bin/perl -w

use Capability::CoreferenceResolution;

use Data::Dumper;
use File::Slurp;

my $coref = Capability::CoreferenceResolution->new;

my $string = read_file($ARGV[0]);

print Dumper
  ($coref->ReplaceCoreferences
   (Text => $string));
