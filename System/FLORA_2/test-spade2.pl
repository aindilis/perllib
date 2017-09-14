#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::FLORA_2::Python::FLORA_2_SPADE;

my $flora2 = System::FLORA_2::Python::FLORA_2_SPADE->new();

$flora2->loadModule('temp');
my $seen = {};
foreach my $result ($flora2->ask('?X(need):?Y')) {
  $seen->{$result->{X}} = 1;
}
print join("\n", sort keys %$seen)."\n";
