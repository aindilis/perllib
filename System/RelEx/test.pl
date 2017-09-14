#!/usr/bin/perl -w

use System::RelEx;

my $relex = System::RelEx->new;

my $text = `cat "/var/lib/myfrdcsa/datasets/personal-writings/artificialintelligence.txt"`;
$relex->Parse(Text => $text);
