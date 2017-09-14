#!/usr/bin/perl -w

use System::Enju::UniLang::Client;

use Data::Dumper;

my $enju = System::Enju::UniLang::Client->new;

$enju->StartEnju;
print Dumper
  ($enju->ApplyEnjuToSentence
   (
    Sentence => "This is a test.",
   ));
