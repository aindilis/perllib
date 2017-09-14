#!/usr/bin/perl -w

use Data::Dumper;
use DateTime;

my $epoch = "1224134011";
$dt = DateTime->from_epoch( epoch => $epoch );

print $dt->year."-".$dt->month."-".$dt->day."\n";




