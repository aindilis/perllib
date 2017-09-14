#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use Regexp::Common qw[Email::Address];
use Email::Address;

# print Dumper({Regex => $RE{Email}{Address}});

my $t1 = "                    result.append(r)\n";
my $t2 = "result.append(r)\n";

if ($t2 =~ /($RE{Email}{Address})/g) {
  print "hi\n";
} else {
  print "ho\n";
}
