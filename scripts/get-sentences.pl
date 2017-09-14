#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use Lingua::EN::Sentence qw(get_sentences);

my $c = read_file($ARGV[0]);
my $sentences = get_sentences($c);
my @res;
foreach my $sentence (@$sentences) {
  $sentence =~ s/[\t\r\n]+/ /g;
  $sentence =~ s/[^[:ascii:]]+/ /g;
  $sentence =~ s/[[:cntrl:]]+/ /g;
  $sentence =~ s/\s+/ /g;
  push @res, $sentence;
}
print join("\n", @res);
