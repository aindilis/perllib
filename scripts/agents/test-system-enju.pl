#!/usr/bin/perl -w

use System::Enju::UniLang::Client;

use Data::Dumper;

my $client = System::Enju::UniLang::Client->new;

$client->StartEnju;
print Dumper
  ($client->ApplyEnjuToSentence
   (Sentence => "This is a test."));
