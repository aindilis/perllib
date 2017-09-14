#!/usr/bin/perl -w

# use Text::Ligature qw(:all);

# my $text = 'ﬁrst prize';

# my $res = from_ligatures($text);

# print $res."\n";


use PerlLib::SwissArmyKnife;
use PerlLib::ToText::StrangeCharacters;

my $text = 'ﬁrst prize';

my $res = from_strange_characters (Text => $text);

print Dumper($res);

my $text = $res->{Text};

my $res2 = to_strange_characters (Text => $text);

print Dumper($res2);
