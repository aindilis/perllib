package Capability::ILP;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "Igor2";
  $self->Name($name);
  require "Capability/ILP/Engine/$name.pm";
  $self->Engine("Capability::ILP::Engine::$name"->new());
}

sub StartServer {
  my ($self,%args) = @_;
  $self->Engine->StartServer;
}

sub StartClient {
  my ($self,%args) = @_;
  $self->Engine->StartClient;
}

sub ProcessData {
  my ($self,%args) = @_;
  return $self->Engine->ProcessData(Data => $args{Data});
}

1;
