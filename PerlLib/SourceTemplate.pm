package PerlLib::SourceTemplate;

# wrapper to be used in conjunction with PerlLib::SourceManager;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Loaded Updated /

  ];

# this is a system to update /etc/apt/sources.list intelligently

sub init {
  my ($self,%args) = (shift,@_);
  Message(Message => "Function <init> not implemented");
}

sub UpdateSource {
  my ($self,%args) = (shift,@_);
  Message(Message => "Function <UpdateSource> not implemented");
  $self->Updated(1);
}

sub LoadSource {
  my ($self,%args) = (shift,@_);
  Message(Message => "Function <LoadSource> not implemented");
  $self->Loaded(1);
}

1;
