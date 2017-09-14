#!/usr/bin/perl -w

use Data::Dumper;

sub DumperQuote {
  my ($arg) = @_;
  my $string = Dumper($arg);
  if ($string =~ /^\$VAR1 = (\[\s+)?(\'.*\')(\s+\])?;$/sm) {
    return $2;
  } else {
    return $string;
  }
}

my $item = '\'"/?FJS)
9fj#)9jfewFJElose\'
';

print "<".DumperQuote($item).">\n";

