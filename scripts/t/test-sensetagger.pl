#!/usr/bin/perl -w

use System::SuperSenseTagger;

my $tagger = System::SuperSenseTagger->new;

my $c = `cat /var/lib/myfrdcsa/datasets/personal-writings/artificialintelligence.txt`;

$tagger->SenseTag(Text => $c);

