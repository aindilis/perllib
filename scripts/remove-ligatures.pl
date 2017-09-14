#!/usr/bin/perl -w

# use Text::Ligature qw(:all);

# my $text = 'ﬁrst prize';

# my $res = from_ligatures($text);

# print $res."\n";

use PerlLib::SwissArmyKnife;
use PerlLib::ToText::StrangeCharacters;

while (<STDIN>) {
  my $res = from_strange_characters(Text => $_);
  print $res->{Text};
}
