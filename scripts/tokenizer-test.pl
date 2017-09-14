#!/usr/bin/perl -w

use Rival::String::Tokenizer2;

use Data::Dumper;

my $text = `cat /var/lib/myfrdcsa/datasets/personal-writings/aiadvocacy.txt`;
my $tokenizer = Rival::String::Tokenizer2->new();
print Dumper
  ($tokenizer->Tokenize
  (
   Tokenizer => "textmine",
   Text => $text,
  ));

