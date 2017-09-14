#!/usr/bin/perl -w

use Capability::SentenceSimilarity;

use Data::Dumper;

print Dumper
  (SentenceSimilarity
   (
    A => "The quick brown fox jumped over the lazy dogs",
    B => "The story went rather well for the first part",
   ));
