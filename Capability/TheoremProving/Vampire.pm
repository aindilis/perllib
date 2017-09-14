package Capability::TheoremProving::Vampire;

use base qw(Capability::TheoremProving);

use Data::Dumper;

# template for system interfaces

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
}

1;
