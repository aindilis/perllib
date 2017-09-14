package PerlLib::NLP::IE;

use PerlLib::NLP::Corpus;

use Data::Dumper;
use Lingua::EN::Tagger;
use String::Tokenizer;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyCorpus MyTokenizer MyTagger Data /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyCorpus
    ($args{Corpus} || PerlLib::Corpus->new());
  $self->MyTokenizer(String::Tokenizer->new());
  $self->MyTagger(Lingua::EN::Tagger->new);
  $self->Data({});
}

sub ExtractObjectNames {
  my ($self,%args) = @_;
  # now for each text file, analyze its contents using TFIDF
  print "Extracting Object Names\n";
  foreach my $doc ($self->MyCorpus->Documents->Values) {
    if (1) {
      # set the name
      $self->Data->{$doc->ID}->{n} =
	$doc->Data->{n};
    }
    if (0) {
      # tokenize the text
      $self->MyTokenizer->tokenize($doc->Contents);
      $self->Data->{$doc->ID}->{t} =
	[$self->MyTokenizer->getTokens()];
    }
    if (0) {
      # get the words
      $self->Data->{$doc->ID}->{np} =
	{$self->MyTagger->get_words( $doc->Contents )};
    }
    if (1) {
      # pos tag the text then get noun phrases
      my $tagged_text = $self->MyTagger->add_tags( $doc->Contents );
      $self->Data->{$doc->ID}->{np} =
	{$self->MyTagger->get_noun_phrases( $tagged_text )};
    }
  }
}

1;
