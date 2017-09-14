#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;

use HTML::Strip;

$specification = q(
	-f <file>		File to process
	-t <text>		Text to process
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

if (exists $conf->{'-f'}) {
  my $f = $conf->{'-f'};
  if (-f $f) {
    $text = read_file($f);
  }
} elsif (exists $conf->{'-t'}) {
  $text = $conf->{'-t'};
}

# my $result = Parse::IRCLog ->parse("/home/andrewdo/dmiles-convo-20170712.txt");
my $hs = HTML::Strip->new();

my $c = $text;

print $c."\n";

my @results;
my @lines = $c =~ /(.*?)(\d{2}:\d{2}:\d{2})(.*?)/sg;
shift @lines;
my @allclean;
while (@lines) {
  my $time = shift @lines;
  my $tmp = shift @lines;
  my $content = shift @lines;

  # my $cleaned = $hs->parse( $content );
  my $cleaned = parse($content);

  my $hash =
    {
     Time => $time,
     Content => $content,
     Cleaned => $cleaned,
    };
  push @allclean, $cleaned;
  push @results, $hash;
}

if (0) {
  print Dumper(\@results);
} else {
  print join("\n", @allclean)."\n";
}

sub parse {
  my $text = shift;
  $text =~ s/<x-color>/ /sg;
  $text =~ s/<\/x-color>/ /sg;
  my $copy = $text;
  my @res = $text =~ /(.*?)<([^\/<][^>]+)>(.*?)/sg;
  my $tokens = {};
  while (@res) {
    my $tmp1 = shift @res;
    my $token = shift @res;
    my $tmp2 = shift @res;
    $tokens->{$token} = 1;
    $copy =~ s/<$token>.*?<\/$token>/ /sg;
  }
  $copy =~ s/<[^>]+>/ /sg;
  $copy =~ s/\s+/ /sg;
  $copy =~ s/^\s*//;
  $copy =~ s/\s*$//;
  return $copy;
}
