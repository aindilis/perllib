#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $item = "it\n";

print Dumper($item);
my $res = chomp($item);
print Dumper({
	      Res => $res,
	      Item => $item,
	     });
