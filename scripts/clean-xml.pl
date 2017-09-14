#!/usr/bin/perl -w

use XML::Simple;

my $file = shift;
exit unless -f $file;
my $contents = `cat "$file"`;
print XMLout(XMLin($contents))."\n";
