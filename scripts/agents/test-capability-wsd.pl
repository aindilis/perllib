#!/usr/bin/perl -w

use Capability::WSD::UniLang::Client;

use Data::Dumper;

my $client = Capability::WSD::UniLang::Client->new;

$client->StartServer;

print Dumper
  ($client->ProcessText
   (Text => "This is a test."));
