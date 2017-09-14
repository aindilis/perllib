#!/usr/bin/perl -w

use System::Cyc::UniLang::Client;

use Data::Dumper;

my $client = System::Cyc::UniLang::Client->new;

$client->StartCyc;
print Dumper
  ($client->Query
   (
    Query => '(#$isa ?X #$Researcher)',
    Mt => 'EverythingPSC',
   ));
