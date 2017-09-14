#!/usr/bin/perl -w

use Data::Dumper;
use File::Slurp;

my $c = read_file("/var/lib/myfrdcsa/sandbox/sst-1.0/sst-1.0/SST-1.0/SST-1.0/DEMO/TEST.WNSS_SST");
my @entries;
foreach my $line (split /\n/, $c) {
  my @items = split /\t/, $line;
  shift @items;
  my @sentence;
  foreach my $item (@items) {
    if ($item =~ /^(.+)\s+([A-Z,.():\$]+)\s+(.+)$/) {
      my $word = $1;
      my $pos = $2;
      my $class = $3;
      my $classdata = {};
      if ($class =~ /^([A-Z])-(\w+).(\w+)$/) {
	$classdata = {
		      ClassLetter => $1,
		      ClassPOS => $2,
		      ClassModifier => $3,
		     };
      }
      push @sentence, {
		       Word => $word,
		       POS => $pos,
		       Class => $classdata,
		      };
    }
  }
  push @entries, \@sentence;
}

print Dumper(\@entries);
