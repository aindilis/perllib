#!/usr/bin/perl -w

use PerlLib::HTMLUtil;

use Data::Dumper;
use File::Slurp;

my $testdata = "/var/lib/myfrdcsa/codebases/internal/perllib/t/data/IPCData.html";
my $contents = read_file($testdata);
my $title = ExtractTitle($contents);
print Dumper($title);

1;
