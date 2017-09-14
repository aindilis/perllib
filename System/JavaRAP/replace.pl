#!/usr/bin/perl -w

use Data::Dumper;

my $res = `cat result`;
my $text = `cat briefandervater.txt`;

print Dumper(Replace
  (
   Text => $text,
   RAPInfo => $res,
  ));

sub Replace {
  my %args = @_;
  my $text = $args{Text};
  my $info = $args{RAPInfo};
  if ($info =~ /\*+Head of Results\*+\s+(.+)\s+\*+End of Results\*+/sm) {
    foreach my $line (split /\n/, $1) {
      $line =~ s/,$//;
      my ($a,$b) = split / <-- /, $line;
      # unfinished, don't know how the JavaRAP output works
    }
  }
}

