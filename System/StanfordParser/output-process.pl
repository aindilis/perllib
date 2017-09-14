#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $c = read_file("sample-output.txt");

$c =~ s/.*Parsing file: (.+?) with (\d+) sentences.\n//s;
$c =~ s/\n\nParsed file: (.+?) \[(\d+) sentences\]\..*//s;

my @items = split /\n\n/, $c;

my @res;
while (@items) {
  my ($tmp,$rel) = (shift @items, shift @items);
  if ($tmp =~ /(.+?)$(.+)/sm) {
    my $sent = $1;
    $tree = $2;
    $tree =~ s/^\s+//s;
    push @res, {
		Sent => $sent,
		Tree => $tree,
		Rel => [split /\n/, $rel],
	       };

  } else {
    die "Error\n";
  }
}

print Dumper(\@res);

