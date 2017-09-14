package Capability::POSTagging;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "GPoSTTL";
  $self->Name($name);
  require "Capability/POSTagging/$name.pm";
  $self->Engine("Capability::POSTagging::$name"->new());
  $self->StartServer;
  $self->StartClient;
}

sub StartServer {
  my ($self,%args) = @_;
  $self->Engine->StartServer;
}

sub StartClient {
  my ($self,%args) = @_;
  $self->Engine->StartClient;
}

sub Tag {
  my ($self,%args) = @_;
  return $self->Engine->Tag(%args);
}

1;
