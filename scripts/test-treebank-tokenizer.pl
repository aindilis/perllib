#!/usr/bin/perl -w

use Capability::Tokenize;

use Data::Dumper;

my $file = "/var/lib/myfrdcsa/datasets/personal-writings/aioverview.txt";
my $text = `cat "$file"`;

print tokenize_treebank($text);
