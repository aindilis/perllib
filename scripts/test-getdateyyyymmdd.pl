#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $res = GetDateYYYYMMDD();
print Dumper({Res => $res});
