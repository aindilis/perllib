#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $data = DeDumperFile('/var/lib/myfrdcsa/codebases/internal/perllib/Capability/WebSearch/results.dat');
my $value = scalar @$data;
print $value."\n";
