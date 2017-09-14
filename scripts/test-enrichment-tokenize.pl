#!/usr/bin/perl -w

use Capability::Enrichment::Tokenize;
use PerlLib::SwissArmyKnife;

my $tokenizer = Capability::Enrichment::Tokenize->new();

my $text = read_file("/var/lib/myfrdcsa/codebases/internal/perllib/sample-writing.txt");

$tokenizer->tokenize($text);
print Dumper([$tokenizer->getTokens()]);
