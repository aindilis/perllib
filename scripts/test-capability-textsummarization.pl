#!/usr/bin/perl -w

use Capability::TextSummarization;
use PerlLib::SwissArmyKnife;

my $summarizer = Capability::TextSummarization->new
  (
   EngineName => "MEAD",
  );

$summarizer->StartServer();

my $sampletext = read_file("/var/lib/myfrdcsa/datasets/personal-writings/artificialintelligence.txt");
 print Dumper
  ($summarizer->SummarizeText
   (Text => $sampletext));
