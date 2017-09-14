package Capability::SentenceSimilarity;

# most of the code here taken from: meteor.pl

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (SentenceSimilarity);

use lib "/var/lib/myfrdcsa/sandbox/meteor-0.6/meteor-0.6/";

use mStageMatcher;

use Data::Dumper;
use WordNet::QueryData;

my $wn;

my $opt_lang = "en";

my %params;
$params{'en'} = '.8 .83 .28';

my ($alpha, $beta, $gamma) = split /\s+/,$params{$opt_lang};

sub SentenceSimilarity {
  my %args = @_;
  if (! $wn and $args{WN}) {
    $wn = WordNet::QueryData->new;
  }
  my %inputHash = ();
  my %wnValidForms         = ();
  my %wnSynsetOffsetHashes = ();

  # Set the language
  $inputHash{"language"}  = $opt_lang;

  # put in the two strings
  $inputHash{"firstString"}  = $args{A};
  $inputHash{"secondString"} = $args{B};

  # set maxComputations
  $inputHash{"maxComputations"} = 10000;

  # put in the modules array
  $inputHash{"modules"} =
    [
     # 'exact',
     'porter_stem',
    ];
  if ($args{WN}) {
    # push @{$inputHash{"modules"}}, 'wn_stem', 'wn_synonymy';
  }

  # pass in stop hash (maybe an empty one!)
  %{ $inputHash{"stop"} } = (); # %stopHash;

  # Make sure pruning is set to "on"
  $inputHash{"prune"} = 1;

  # put in the detail flag to find out number of computations being done
  $inputHash{"details"} = 0;

  # if $wn is defined, send the WordNet object along
  if ( defined $wn ) {
    $inputHash{"wn"}                   = $wn;
    $inputHash{"wnValidForms"}         = \%wnValidForms;
    $inputHash{"wnSynsetOffsetHashes"} = \%wnSynsetOffsetHashes;
  }

  match(\%inputHash);
  my %scoresHash = ();

  # Count up the total number of matches across all the stages
  $scoresHash{"totalMatches"} = 0;
  for ( my $i = 0 ; $i <= $#{ $inputHash{"matchScore"} } ; $i++ ) {
    my $numMatches = ${ $inputHash{"matchScore"} }[$i][0];
    my $numFlips   = ${ $inputHash{"matchScore"} }[$i][1];
    $scoresHash{"totalMatches"} += $numMatches;
  }

  # print the num chunks and avg chunk lengh
  $scoresHash{"numChunks"} = $inputHash{"numChunks"};

  #       print "  Reference: $referenceID, ";
  #       print "Matches found: " . $scoresHash{"totalMatches"} . ", ";
  #       print "Chunks found: " . $scoresHash{"numChunks"} . "\n";

  # get the lengths of the two strings
  $scoresHash{"hypLength"} = $inputHash{"sizeOfFirstString"};
  $scoresHash{"refLength"} = $inputHash{"sizeOfSecondString"};

  # compute the score and all the other metrics for this scores hash
  # for this hypothesis - reference pair
  # When total matches == 0, then score is defined to be 0, and all
  # other measures are undefined.
  computeMetrics( \%scoresHash );
  return \%scoresHash;
}

sub computeMetrics {
    my $scoresHashRef = shift;

    if ( ${$scoresHashRef}{"totalMatches"} == 0 ) {
        ${$scoresHashRef}{"score"} = 0;
    }
    else {

        # compute precision, recall, f1 and fmean
        ${$scoresHashRef}{"precision"} = ${$scoresHashRef}{"totalMatches"} / ${$scoresHashRef}{"hypLength"};
        ${$scoresHashRef}{"recall"}    = ${$scoresHashRef}{"totalMatches"} / ${$scoresHashRef}{"refLength"};
        ${$scoresHashRef}{"f1"}        = 2 * ${$scoresHashRef}{"precision"} * ${$scoresHashRef}{"recall"} /
          ( ${$scoresHashRef}{"precision"} + ${$scoresHashRef}{"recall"} );

	${$scoresHashRef}{"fmean"} = 1 / ( ( (1 - $alpha) / ${$scoresHashRef}{"precision"} ) + ( $alpha / ${$scoresHashRef}{"recall"} ) );
        # compute fragmentation and penalty
        if ( ${$scoresHashRef}{"totalMatches"} ==  ${$scoresHashRef}{"hypLength"} && 
		${$scoresHashRef}{"totalMatches"} ==  ${$scoresHashRef}{"refLength"} &&
		${$scoresHashRef}{"numChunks"} == 1) {
	# Special check to handle the case when the hypothesis and reference are identical.
            ${$scoresHashRef}{"frag"}    = 0;
        }
        else {
            ${$scoresHashRef}{"frag"} = ${$scoresHashRef}{"numChunks"} / ${$scoresHashRef}{"totalMatches"};
        }

        ${$scoresHashRef}{"penalty"} = $gamma * ( ${$scoresHashRef}{"frag"}**$beta );

        # compute score based on fmean fragmentation and pentaly.
        ${$scoresHashRef}{"score"} = ${$scoresHashRef}{"fmean"} * ( 1 - ${$scoresHashRef}{"penalty"} );
    }
}

1;
