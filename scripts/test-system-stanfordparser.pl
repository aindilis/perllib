#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::StanfordParser;

my $parser = System::StanfordParser->new;

my $c = read_file("artificialintelligence.txt");

my $res = $parser->ProcessText
  (
   Text => $c,
  );
print Dumper($res);
