#!/usr/bin/perl -w

use Capability::WebSearch;
use PerlLib::SwissArmyKnife;

# my $websearch = Capability::WebSearch->new
#   (
#    ViewHeadless => 1,
#    Method => 'normal',
#   );

my $websearch = Capability::WebSearch->new
  (
   EngineName => 'DuckDuckGo',
   ViewHeadless => 1,
   # Method => 'normal',
   Method => 'normal',
  );

# Capability::WebSearch::Engine::DuckDuckGo

print Dumper
  ($websearch->WebSearch
   (
    Search => 'natural language understanding software download',
    NumberOfResults => 100,
   ));
