#!/usr/bin/perl -w

use Capability::Tokenize;
use PerlLib::MySQL;

use Data::Dumper;

my $mysql = PerlLib::MySQL->new
  (DBName => "unilang");

foreach my $entry (values %{$mysql->Do(Statement => "select ID, Contents from messages")}) {
  my $text = $entry->{Contents};
  if ((length($text) > 50)) { #  and ($text =~ /^[a-zA-Z0-9\s]+.$/)) {
    print "$text\n";
    my $t1 = tokenize_treebank($text);
    my $t2 = tokenize_treebank_2($text)."\n";
    if ($t1 ne $t2) {
      print "\t$t1\n\t$t2\n";
    }
  }
}

# FIX ME, doesn't work on certain cases, name "80" -> `` 8 0 ''
# instead of `` 80 ''

sub tokenize_treebank_2 {
  my $item = shift;
  $item =~ s/^"/`` /g;
  $item =~ s/([ ([{<])"/$1 `` /g;
  $item =~ s/\.\.\./ ... /g;
  # $item =~ s/[,;:@#$%&]/ & /g;
  $item =~ s/([,;:@#$%&])/ $1 /g;
  $item =~ s/([^.])([.])([])}>"']*)[ 	]*$/$1 $2$3 /g;
  # $item =~ s/[?!]/ & /g;
  $item =~ s/([?!])/ $1 /g;

  # $item =~ s/[][(){}<>]/ & /g;
  $item =~ s/([][(){}<>])/ $1 /g;
  $item =~ s/--/ -- /g;
  $item =~ s/$/ /;
  $item =~ s/^/ /;
  $item =~ s/"/ '' /g;
  $item =~ s/([^'])' /$1 ' /g;
  $item =~ s/'([sSmMdD]) / '$1 /g;
  $item =~ s/'ll / 'll /g;
  $item =~ s/'re / 're /g;
  $item =~ s/'ve / 've /g;
  $item =~ s/n't / n't /g;
  $item =~ s/'LL / 'LL /g;
  $item =~ s/'RE / 'RE /g;
  $item =~ s/'VE / 'VE /g;
  $item =~ s/N'T / N'T /g;
  $item =~ s/ ([Cc])annot / $1an not /g;
  $item =~ s/ ([Dd])'ye / $1' ye /g;
  $item =~ s/ ([Gg])imme / $1im me /g;
  $item =~ s/ ([Gg])onna / $1on na /g;
  $item =~ s/ ([Gg])otta / $1ot ta /g;
  $item =~ s/ ([Ll])emme / $1em me /g;
  $item =~ s/ ([Mm])ore'n / $1ore 'n /g;
  $item =~ s/ '([Tt])is / '$1 is /g;
  $item =~ s/ '([Tt])was / '$1 was /g;
  $item =~ s/ ([Ww])anna / $1an na /g;
  $item =~ s/  */ /g;
  $item =~ s/^ *//g;
  return $item;
}
