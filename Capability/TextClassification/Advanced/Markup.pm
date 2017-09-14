package Capability::TextClassification::Advanced::Markup;

use Capability::TextAnalysis;

use Data::Dumper;
use WordNet::QueryData;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyTextAnalysis MySayer Features /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MySayer
    (Sayer->new
     (
      DBName => $args{DBName},
     ));
  $self->MyTextAnalysis
    (Capability::TextAnalysis->new
     (
      Sayer => $self->MySayer,
      DontSkip => {
		   "NounPhraseExtraction" => 1,
		   "Tokenization" => 1,
		   "TermExtraction" => 1,
		   "MontyLingua" => 1,
		   "DateExtraction" => 1,
		  },
      Skip => {
	       "NamedEntityRecognition" => 1,
	       "SemanticAnnotation" => 1,
	       "CoreferenceResolution" => 1,
	       "WSD" => 1,
	       "FactExtraction" => 1,
	      },
     ));
}

sub Markup {
  my ($self,%args) = @_; 
  # take the text, add a bunch of features to it
  print Dumper({MarkupInput => $args{Text}});
  my $results = $self->MyTextAnalysis->AnalyzeText
    (Text => $args{Text});
  print Dumper({MarkupOutput => $results});

  my $textwithfeaturesadded = $args{Text};

  # now we need to call the formalize system on this particular item
  # Capability::TextAnalysis2

  # foreach bit of data processed by it
  # create an entry
  # for each word in it

  # create an Enju2 that processes in additional information, such as
  # WSD information

  # the point is to take text and turn it into logic forms

  return {
	  TextWithFeaturesAdded => $textwithfeaturesadded,
	 };
}

sub AddSubsumptionFeatures {
  my ($self,%args) = @_;
  my $token = $args{Token};
  my $features = {};
  if (! exists $features->{$token}) {
    my @senses = $self->MyWSD->MyQueryData->querySense("$token#n");
    my @all;
    foreach my $starter (@senses) {
      my @hist;
      my @list = ($starter);
      while (@list) {
	my $item = shift @list;
	push @hist, $item;
	# print $item."\n";
	push @list, $self->MyWSD->MyQueryData->querySense($item,"hypes")
      }
      push @all, \@hist;
    }
    $features->{$token} = \@all;
  }
  return $features->{$token};
}

1;
