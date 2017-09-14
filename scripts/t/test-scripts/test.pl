#!/usr/bin/perl -w

use WWW::Search;
my $oSearch = new WWW::Search('Yahoo');
my $sQuery = WWW::Search::escape_query("gamera");
$oSearch->native_query($sQuery);
while (my $oResult = $oSearch->next_result()) {
  print $oResult->url, "\n";
}

