#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use XML::Simple;

# this attempts to postprocess the results of the Shalmaneser

my $file = "shal.output";
my $c = read_file($file);
my $xs = XML::Simple->new();
my $ref = $xs->XMLin($c);
my $ie = KBS2::ImportExport->new;

my @kb;
foreach my $sentence (keys %{$ref->{body}->{s}}) {
  my $terminals = $ref->{body}->{s}->{$sentence}->{graph}->{terminals}->{t};
  my $nonterminals = $ref->{body}->{s}->{$sentence}->{graph}->{nonterminals}->{nt};
  my $frames = $ref->{body}->{s}->{$sentence}->{sem}->{frames}->{frame};
  my $result = {
		Terminals => $terminals,
		Nonterminals => $nonterminals,
		Frames => $frames,
	       };
}
