#!/usr/bin/perl -w

use System::CAndC;

use Data::Dumper;
use File::Slurp;

my $candc = System::CAndC->new;
my $c = read_file("sample.txt");

$candc->StartServer;
foreach my $line (split /\n/, $c) {
  print Dumper($candc->CallClient(Text => $line));
}


