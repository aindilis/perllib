#!/usr/bin/perl -w

use Rival::Yahoo::Search;

use Data::Dumper;

my @result = Rival::Yahoo::Search->Results(Doc => '"question answering"   system OR java OR project OR library OR php OR web OR framework OR open OR manager OR linux OR engine OR net OR server OR management OR game OR tool OR tools OR client OR simple OR editor OR cms OR database OR file OR generator
');
print Dumper(\@result);
