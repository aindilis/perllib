#!/usr/bin/perl -w

use KBS2::Util;
use PerlLib::SwissArmyKnife;

my $string = 'this is \'a\' "test" $KLJFIWJEQFJEJF %#%@J#@';
print shell_quote($string)."\n";

print EmacsQuote(Arg => $string)."\n";
