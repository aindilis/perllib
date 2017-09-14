package PerlLib::Allocator::Item;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / ItemRef Cost Value /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ItemRef($args{ItemRef});
  $self->Cost($args{Cost});
  $self->Value($args{Value});
}

1;
