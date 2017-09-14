package PerlLib::NLP::Corpus::Document;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / ID File Contents /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ID
    ($args{ID});
  $self->File
    ($args{File});
  $self->Contents
    ($args{Contents});
}

1;
