#!/usr/bin/perl -w

my $f = `cat qe.txt`;
eval $f;
my $h = $VAR1;
my $threshold = shift @ARGV;
foreach my $item (sort {$h->{$b} <=> $h->{$a}} keys %$h) {
  if ($h->{$item} > $threshold) {
    print "ys";
  } else {
    print "no";
  }
  print " $item\n";
}
