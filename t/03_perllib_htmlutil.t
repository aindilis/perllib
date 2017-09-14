#!/usr/bin/perl -w

use Test::More no_plan;
use File::Slurp;

use_ok('PerlLib::HTMLUtil');

my $testdata = "/var/lib/myfrdcsa/codebases/internal/perllib/t/data/IPCData.html";
my $contents = read_file($testdata);
my $title = ExtractTitle($contents);
is($title->[0], "IPCData \x{2014} The Seventh International Planning Competition 1.3 documentation", 'title extracts');

1;
