#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::Cyc::Util;

my $text = 'thidsfds\'" is  a 5t2380582809*%(%%)(&%&)';

print Dumper(QuoteForCyclify(Text => $text));
