package System::OpinionFinder;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Proxy  /

  ];

sub init {
  my ($self,%args) = @_;
}

sub ProcessSentences {
  my ($self,%args) = @_;
  # "python opinionfinder.py -f examples/perllib.doclist"
}

1;
