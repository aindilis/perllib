#!/usr/bin/perl -w

use PerlLib::ToText::StrangeCharacters;

$PerlLib::ToText::StrangeCharacters::debug = 1;

my $text = `zcat thediss.pdf.voy.gz`;

list_strange_characters(Text => $text);
