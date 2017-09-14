#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;

use URL::Encode qw(url_encode);

$specification = q(
	-f <file>		File containing searches
	-s <search>...		Searches
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $searches;
if (exists $conf->{'-s'}) {
  @searches = @{$conf->{'-s'}};
} elsif ($conf->{'-f'}) {
  if (-f $conf->{'-f'}) {
    my $tmp = read_file($conf->{'-f'});
    @searches = split /\n/, $tmp;
  } else {
    die "No such file <".$conf->{'-f'}.">\n";
  }
}

foreach my $search (@searches) {
  my $encodedsearch = url_encode($search);
  my $lcencodedsearch = lc($encodedsearch);
  my $dashedsearch = join('-',split(/\s+/,$search));
  my $search1 = join('%2520',split(/\s+/,$search));
  my $lcdashedsearch = lc($dashedsearch);
  my $lcsearch1 = lc($search1);
  my $url = "https://www.google.com/\#safe=active\&q=$encodedsearch";
  print "<$url>\n";
  my $c = "firefox -new-tab -url ".shell_quote($url);
  print "$c\n";
  system $c;
}
