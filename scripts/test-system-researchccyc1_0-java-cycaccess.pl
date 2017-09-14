#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::Cyc::ResearchCyc1_0::Java::CycAccess;

use Inline::Java qw(caught);

my $cycaccess = System::Cyc::ResearchCyc1_0::Java::CycAccess->new();

my $cyclist = $cycaccess->makeCycList('(#$isa ?X #$Researcher)'),
my $mt = $cycaccess->getKnownConstantByName("EverythingPSC");
my $properties;
eval {
  $properties = $cycaccess->createInferenceParams();
};
if ($@) {
  print $@->getMessage()."\n";
}


my $result;
eval {
  $result = $cycaccess->askNewCycQuery($cyclist, $mt, $properties)
} ;
if ($@) {
  print $@->getMessage()."\n";
}

my @result;
my $e1 = $result->listIterator(0);
while ($e1->hasNext()) {
  my $o1 = $e1->next();
  if (ref($o1) eq 'System::Cyc::ResearchCyc1_0::Java::CycAccess::org::opencyc::cycobject::CycList') {
    push @result, [\*{'::'.$o1->first()->first()->toString},$o1->first()->last()->cyclify()];
  }
}

print Dumper([\@result]);
