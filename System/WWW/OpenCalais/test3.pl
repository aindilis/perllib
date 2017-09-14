#!/usr/bin/perl -w

use Data::Dumper;
use Net::Calais;

my $key = '<REDACTED>';
my $contents = `cat artificialintelligence.txt`;

my $calais = Net::Calais->new(apikey => $key);

# TEXT/Simple
# TEXT/HTML

print Dumper($calais->enlighten($contents, outputFormat => 'TEXT/Simple'));
