#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use PerlLib::TFIDF;
use Rival::String::Tokenizer;

use String::Similarity;

my $resultsfile = '/var/lib/myfrdcsa/codebases/minor/media-library/data/play-movie/movies-result.pl';

my $data = DeDumperFile($resultsfile);

my $description = 'Lord of the Rings';


# now search for the description
my $sim = {};
my $texthash = {};
my @entries = keys %$data;

my $entries = {};
foreach my $entry (@entries) {
  foreach my $location (@{$data->{$entry}{Location}}) {
    $entries->{$location} = 1;
  }
}

if (0) {
  foreach my $entry (keys %$entries) {
    $sim->{$entry} = similarity($entry,$description);
    $texthash->{$entry} = $entry;
  }
}

# print Dumper({Entries => $entries});

if (0) {
  my $tfidf = PerlLib::TFIDF->new();
  $entries->{$description} = 1;
  $tfidf->Entries($entries);
  $tfidf->ComputeTFIDF;

  print Dumper($tfidf);
}

if (1) {
  my $descriptiontokens = {};
  my $score = {};
  foreach my $token (split /\W/, lc($description)) {
    $descriptiontokens->{$token} = 1;
  }

  foreach my $entry (keys %$entries) {
    $score->{$entry} = 0;
    foreach my $token (split /\W/, lc($entry)) {
      if (exists $descriptiontokens->{$token}) {
	$score->{$entry}++;
      }
    }
  }
  foreach my $entry (sort {$score->{$b} <=> $score->{$a}} keys %$entries) {
    print $score->{$entry}.' '.$entry."\n";
  }
}

if (0) {
  my $tokenizer = Rival::String::Tokenizer->new();
  $tokenizer->tokenize($description);
  my @res1 = $tokenizer->getTokens();
  print Dumper({Res1 => \@res1});
  die;
}
