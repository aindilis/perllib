#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $contents = read_file($ARGV[0]);
print Dumper(ExtractAbbreviations(Text => $contents));

sub ExtractAbbreviations {
  my %args = @_;
  my $requirecaps = 1;
  my $matches = {};
  my $matches2 = {};
  my @tokens = split /\b/, $args{Text};
  my @tokens2;
  my @queue = ();
  my @queue2 = ();
  foreach my $token (@tokens) {
    if ($token =~ /^[A-Z]{2,}$/) {
      $matches->{$token} = [split //, lc($token)];
      $matches2->{$token} = {};
    }
    if ($token !~ /^\s+$/) {
      push @tokens2, $token;
    }
  }
  foreach my $token2 (@tokens2) {
    if ($token2 =~ /^(.)/) {
      push @queue, lc($1);
      push @queue2, $token2;
    }
    foreach my $token (keys %$matches) {
      my $match = 1;
      my $i = 1;
      my @currentmatch = ();
      foreach my $letter (reverse @{$matches->{$token}}) {
	if ($queue[-$i] ne $letter) {
	  $match = 0;
	  last;
	} else {
	  if ($requirecaps) {
	    if ($queue2[-$i] =~ /^[^a-z]/) {
	      push @currentmatch, $queue2[-$i];
	    } else {
	      $match = 0;
	      last;
	    }
	  }
	}
	++$i;
      }
      if ($match) {
	$matches2->{$token}->{join(" ",reverse @currentmatch)} = 1;
      }
    }
  }
  @queue = ();
  @queue2 = ();
  my @queue3 = ();
  my $queuedup = [];
  foreach my $token2 (@tokens2) {
    if ($token2 =~ /^(for|to|from|with|of|a|the|and|or)$/i) {
      push @$queuedup, $token2;
      next;
    }
    if ($token2 =~ /^(.)/) {
      push @queue, lc($1);
      push @queue2, $token2;
      push @queue3, $queuedup;
      $queuedup = [];
    }
    foreach my $token (keys %$matches) {
      my $match = 1;
      my $i = 1;
      my @currentmatch = ();
      foreach my $letter (reverse @{$matches->{$token}}) {
	if ($queue[-$i] ne $letter) {
	  $match = 0;
	  last;
	} else {
	  if ($requirecaps) {
	    if ($queue2[-$i] =~ /^[^a-z]/) {
	      push @currentmatch, $queue2[-$i];
	    } else {
	      $match = 0;
	      last;
	    }
	  }
	  if ($i != scalar @{$matches->{$token}} and scalar @{$queue3[-$i]}) {
	    push @currentmatch, @{$queue3[-$i]};
	  }
	}
	++$i;
      }
      if ($match) {
	$matches2->{$token}->{join(" ",reverse @currentmatch)} = 1;
      }
    }
  }
  return {
	  Result => $matches2,
	 };
}
