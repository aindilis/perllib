package Capability::Similarity::Semantic;

use PerlLib::SwissArmyKnife;

use WordNet::QueryData;
use WordNet::Similarity::path;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw/ MyQueryData MySimilarity /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyQueryData
    (WordNet::QueryData->new
     (
      noload => 1,
     ));
  $self->MySimilarity
    (WordNet::Similarity::path->new
     ($self->MyQueryData));
}

sub Similarity {
  my ($self,%args) = @_;
  # my $value = $self->MySimilarity->getRelatedness("car#n#1", "bus#n#2");
  my $value = $self->MySimilarity->getRelatedness($args{A}, $args{B});
  # print Dumper($value);
  return $value;
}

1;
