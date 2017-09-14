#!/usr/bin/perl -w

use Capability::NER;
use Manager::Dialog qw(QueryUser);

my $ner = Capability::NER->new();
while (1) {
  print $ner->NER(Text => QueryUser("NER:"))."\n";
}
