package Capability::NLP::PhraseFrequency;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;

}

sub Frequency {
  my ($self,%args) = @_;

}

# load the latin data
# load the anc data
# load the german data

1;
