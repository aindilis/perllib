#!/usr/bin/perl -w

use Capability::Similarity::Engine::BOW;
use PerlLib::SwissArmyKnife;

my $resultsfile = '/var/lib/myfrdcsa/codebases/minor/media-library/data/play-movie/movies-result.pl';
my $data = DeDumperFile($resultsfile);

# now search for the description
my @entries = keys %$data;

my $entries = {};
foreach my $entry (@entries) {
  foreach my $location (@{$data->{$entry}{Location}}) {
    $entries->{$location} = 1;
  }
}

my $bow = Capability::Similarity::Engine::BOW->new(Entries => $entries);

my $search = 'Lord of the Rings';
my $res1 = $bow->Similarity(Search => $search);
if ($res1->{Success}) {
  my $scores = $res1->{Results};
  my $res1 = $bow->GetSortedScores(Scores => $scores);
  if ($res1->{Success}) {
    foreach my $result (@{$res1->{Results}}) {
      print $scores->{$result}."\t$result\n";
    }
  }
}
