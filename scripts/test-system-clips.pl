#!/usr/bin/perl -w

use System::CLIPS;
my $clips = new System::CLIPS;
$clips->load("animal.clp");
$clips->reset;
$clips->run;
$clips->facts;
