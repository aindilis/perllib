#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;
use System::CAndC;

use Lingua::EN::Sentence qw(get_sentences);

$specification = q(
	-f <file>	File to process
	-t <text>	Text to process
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;

my $candc = System::CAndC->new;

my $text;
if (exists $conf->{'-t'}) {
  $text = $conf->{'-t'};
} elsif (exists $conf->{'-f'} and -f $conf->{'-f'}) {
  $text = read_file($conf->{'-f'});
} else {
  $text = read_file("/var/lib/myfrdcsa/codebases/internal/perllib/scripts/t/aioverview.txt");
}

my $sentences = get_sentences($text);
foreach my $sentence (@$sentences) {
  $sentence =~ s/^\s*//sg;
  $sentence =~ s/\s*$//sg;
  $sentence =~ s/\s+/ /sg;
  print Dumper($candc->GetCCGAndDRS(Text => $sentence));
}


