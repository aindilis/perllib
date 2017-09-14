#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;
use System::WWW::Firefox;

$specification = q(
	-l		List existing searches
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $firefox = System::WWW::Firefox->new();
$firefox->Get();
