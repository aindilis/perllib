package Capability::TheoremProving;

use base qw(Capability);

# base class of all Capability::TheoremProving modules

use Data::Dumper;

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
