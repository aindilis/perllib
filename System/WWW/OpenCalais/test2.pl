#!/usr/bin/perl -w

use System::WWW::OpenCalais;

use Data::Dumper;

my $oc = System::WWW::OpenCalais->new;

my $contents = `cat /home/andrewdo/artificialintelligence.txt`;
print Dumper($oc->Process(Contents => $contents));
