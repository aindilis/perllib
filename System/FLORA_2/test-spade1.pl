#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::FLORA_2::Python::FLORA_2_SPADE;

my $flora2 = System::FLORA_2::Python::FLORA_2_SPADE->new();

# $flora2->('frdcsa');

$flora2->tell('a[ b->c ]');
$flora2->tell('( ?x[ c->?y ] :- ?x[ b->?y ] )', 'insertrule');
foreach my $result ($flora2->ask('?x[ ?y->?z ]')) {
  print Dumper($result);
}
$flora2->retract('a[ b->c ]');
