#!/usr/bin/perl -w

use Data::Dumper;
use Data::URIEncode qw(complex_to_query);

print Dumper(complex_to_query({data => 'fj%TR#@%(#239j90fjewj'}));
