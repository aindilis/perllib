#!/usr/bin/perl -w

use Data::Dumper;
use File::Slurp;
use XML::Smart;

my $res = read_file
  ('result2.txt');

my $xml = XML::Smart->new($res);


my $ids = {};
foreach my $item (@{$xml->{text}{s}}) {
  my $counter = {
		 "w" => 0,
		 "coref" => 0,
		};
  foreach my $thing (@{$item->{'/order'}}) {
    # retrieve this item
    if ($thing eq "coref") {
      my @phrase;
      foreach my $token (@{$item->{"coref"}[$counter->{"coref"}]->{'w'}}) {
	push @phrase, $token->content;
      }
      my $w = join(" ",@phrase);
      my $setid = $item->{"coref"}[$counter->{"coref"}]->{'set-id'}->content;
      $ids->{$setid}->{$w}++;
      ++$counter->{"coref"};
    } else {
      my $w = $item->{"w"}[$counter->{"w"}++]->content;
      # do nothing with this
      $w = "";
    }
  }
}

my @tokens;
foreach my $item (@{$xml->{text}{s}}) {
  my $counter = {
		 "w" => 0,
		 "coref" => 0,
		};
  foreach my $thing (@{$item->{'/order'}}) {
    # retrieve this item
    if ($thing eq "coref") {
      my @phrase;
      foreach my $token (@{$item->{"coref"}[$counter->{"coref"}]->{'w'}}) {
	push @phrase, $token->content;
      }
      my $w = join(" ",@phrase);
      my $setid = $item->{"coref"}[$counter->{"coref"}]->{'set-id'}->content;
      push @tokens, "<<<".join("|", sort keys %{$ids->{$setid}}).">>>";
      ++$counter->{"coref"};
    } else {
      my $w = $item->{"w"}[$counter->{"w"}++]->content;
      # do nothing with this
      push @tokens, $w;
    }
  }
}

print Dumper({
	      String => \@tokens,
	      Ids => $ids,
	     });
