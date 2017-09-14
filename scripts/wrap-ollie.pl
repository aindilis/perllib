#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;
use System::OLLIE;

$specification = q(
	-f <file>		File to process
	-t <text>		Text to process
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $text;
if (exists $conf->{'-f'}) {
  my $f = $conf->{'-f'};
  if (-f $f) {
    $text = read_file($f);
  }
} elsif (exists $conf->{'-t'}) {
  $text = $conf->{'-t'};
}

my $res = ProcessText(Text => $text);
print Dumper({Res => $res});
