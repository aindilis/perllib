#!/usr/bin/perl -w

use BOSS::Config;

use Data::Dumper;

$specification = q(
	-d <duration>	Duration
	-m <message>	Message to print
	-c <command>	Command to be run
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $whoami = `whoami`;
chomp $whoami;
die "Must be run as root\n" unless $whoami eq "root";
die "Need a -c option\n" unless exists $conf->{'-c'};
die "Need a -c option\n" unless exists $conf->{'-m'};
my $max = 3600;

if (exists $conf->{'-d'} and (0 < $conf->{'-d'} and $conf->{'-d'} < $max)) {
  print $conf->{'-m'}."\n";
  while (1) {
    sleep $conf->{'-d'};

    print $conf->{'-c'}."\n";
    system $conf->{'-c'};
  }
} else {
  print "Incorrect usage, use -d <duration> where duration is an integer between 0 and $max\n";
  exit(1);
}
