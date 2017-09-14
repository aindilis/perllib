#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;

$specification = q(
	-f <file>		File containing list of urls
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;

if (! -f $conf->{'-f'}) {
  die "-f file must exist\n";
}

my $c = read_file($conf->{'-f'});

foreach my $url (split /\n/, $c) {
  if ($url =~ /^(ht|f)tps?:\/\//) {
    print "<$url>\n";
    my $c = "firefox -new-tab -url ".shell_quote($url);
    print "$c\n";
    system $c;
  }
}
