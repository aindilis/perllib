#!/usr/bin/perl -w

use Capability::CoreferenceResolution::UniLang::Client;

use Data::Dumper;

my $client = Capability::CoreferenceResolution::UniLang::Client->new;

$client->StartServer;

print Dumper
  ($client->ReplaceCoreferences
   (
    Text => "Loraine besides participating in Broadway's Dreamgirls, also participated in the Off-Broadway production of \"Does A Tiger Have A Necktie\". In 1999, Loraine went to London, United Kingdom. There she participated in the production of \"RENT\" where she was cast as \"Mimi\" the understudy.",
    WithEntities => 1,
   ));
