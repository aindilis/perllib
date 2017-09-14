#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use Text::Capitalize;

my $c = read_file('sample-ollie-output.txt');
my @all;
my @current;
foreach my $line (split /\n/, $c) {
  if ($line !~ /./) {
    my @copy = @current;
    push @all, \@copy;
    @current = ();
  } else {
    if ($line =~ /^([\d\.]+): \((.*)\)$/) {
      print "<$1:$2>\n";
      my $confidence = $1;
      my $input = $2;
      my @parts = split /\s*;\s*/, $input;
      print Dumper(\@parts);
      my $numparts = scalar @parts;
      if ($numparts == 3) {
	push @current, join(' ',@parts);
	print "hey\n";
	print Dumper(\@current);
      } else {
	die Dumper({Parts => \@parts, Number => $numparts});
      }
    } else {
      print "SENT: $line\n";
    }
  }
}
if (scalar @current) {
  my @copy = @current;
  push @all, \@copy;
  @current = ();
}

print Dumper({All => \@all});

foreach my $entry (@all) {
  my $sentences = join('.  ',map {capitalize($_)} @$entry);
  # print $sentences."\n";

  my $qsentences = shell_quote($sentences);
  my $command = "candc-client -ws $qsentences";
  print $command."\n";
  if (0) {
    my $res1 = `$command`;
    print $res1."\n";
  }
}

# The Chinese character xiao (pronounced "sheeow" in a falling, affirmative tone) was originally a highly stylized picture of a gray-haired old person and a young child , reflecting as it does generational deference and the reverence it engenders.
# 0.926: (sheeow; was originally a highly stylized picture of; a gray-haired old person and a young child)
# 0.81: (sheeow; was originally; a highly stylized picture of a gray-haired old person)
# 0.531: (it; does; generational deference and the reverence it engenders)

# This was common in late medieval times, and so it worked better then.
# 0.529: (it; was common in; late medieval times)
# 0.46: (it; was; common)
