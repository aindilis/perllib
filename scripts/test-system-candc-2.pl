#!/usr/bin/perl -w

use System::CAndC;

use Data::Dumper;
use File::Slurp;

my $candc = System::CAndC->new;
my $c = read_file("t/sample.txt");

foreach my $line (split /\n/, $c) {
  print Dumper($candc->LogicForm(Text => $line));
}


