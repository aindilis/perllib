#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;

use Data::Dumper;

$specification = q(
	-f <file>...		Files to split
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;

if ($conf->{'-f'}) {
  foreach my $filename (@{$conf->{'-f'}}) {
    print "<$filename>\n";
    if ($filename =~ /^(.+)\.png$/) {
      my $basename = $1;
      my $pnmfile = "${basename}.pnm";
      DoCommand("pngtopnm ".shell_quote("${basename}.png")." > ".shell_quote($pnmfile));
      if (-f $pnmfile) {
	my $command = 'pamfile '.shell_quote($pnmfile);
	my $pamfile = `$command`;
	# Screenshot from 2013-05-28 09:48:20.pnm:	PPM raw, 3840 by 1080  maxval 255
	if ($pamfile =~ /^${pnmfile}:\s+PPM raw, (\d+) by (\d+)\s+.*$/) {
	  my $width = $1;
	  next unless $width = 1920 * 2;
	  my $height = $2;
	  my $newwidth = $width / 2;
	  my $command2 = 'pamdice -width='.$newwidth.' -height='.$height.' -outstem '.shell_quote($basename).' '.shell_quote($pnmfile);
	  DoCommand($command2);
	}
      }
    }
  }
}

