#!/usr/bin/perl -w

use Data::Dumper;
use WordNet::QueryData;

my $querydata = WordNet::QueryData->new("/usr/local/WordNet-3.0/dict/");

my @text;
try {
  @text = $querydata->querySense("This#ND", "glos");
}
  catch Error with {
    print Dumper({Problem => (shift)});
  };


print Dumper(\@text);
