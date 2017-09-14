#!/usr/bin/perl -w

use System::Shalmaneser;

use Data::Dumper;
use File::Slurp;

my $shal = System::Shalmaneser->new;
my $c = read_file("sample3.txt");
my $res = $shal->ApplyShalmaneserToText
  (Text => $c);
if ($res->{Success}) {
  print $res->{Result}."\n";
}



