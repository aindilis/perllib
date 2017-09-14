package Rival::Symbol::Table::Symbol;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [
   qw / Name Package /
  ];

sub init {
  my ($self,%args) = @_;

}

1;
