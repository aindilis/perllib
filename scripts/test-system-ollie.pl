#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::OLLIE;

my $text = read_file('/var/lib/myfrdcsa/codebases/internal/perllib/System/OLLIE/input.txt');

my $res = ProcessText(Text => $text);
print Dumper({Res => $res});
