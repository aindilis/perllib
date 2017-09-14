#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::Cyc::Java::CycAccess;
use System::Cyc::Java::CycLParserUtil;

use Inline::Java qw(caught);

my $cycaccess = System::Cyc::Java::CycAccess->new();
my $cyclparserutil;

eval {
  $cyclparserutil = System::Cyc::Java::CycLParserUtil->new();
};
if ($@) {
  print $@->getMessage()."\n";
}

eval {
  print Dumper($cyclparserutil->parseCycLSentence("(#\$isa ?X #\$Researcher)"));
};
if ($@) {
  print $@->getMessage()."\n";
}
