#!/usr/bin/perl -W

use PerlLib::SwissArmyKnife;
use System::KBPToolkit;

my $kbp = System::KBPToolkit->new();

$kbp->WriteKBPSlotFillingPAPropertyFile
  ({
    Values => $kbp->DefaultPAPropertyFileValues
    ({
      Values => {},
     }),
   });

$kbp->ExpandQueryNames();
$kbp->KBPPASlotFilling();
$kbp->FilterResultsOfPAPipeline();

print Dumper($kbp->ProcessResults());
