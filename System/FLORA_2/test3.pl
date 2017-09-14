#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::FLORA_2::Python::FLORA_2;

my $flora2 = System::FLORA_2::Python::FLORA_2->new();

$flora2->consult('frdcsa');
