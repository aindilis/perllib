#!/usr/bin/perl -w

use POSIX qw(floor);

my $j = floor(100 / 30);
print $j."\n";

for (my $i = 1; $i <= $j; ++$i) {
  print $i."\n";
}
