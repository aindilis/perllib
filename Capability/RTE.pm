package Capability::RTE;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "Edits";
  $self->Name($name);
  require "RTE/Engine/$name.pm";
  $self->Engine("RTE::Engine::$name"->new());
}

sub StartServer {
  my ($self,%args) = @_;
  $self->Engine->StartServer
    (%args);
}

sub StartClient {
  my ($self,%args) = @_;
  $self->Engine->StartClient;
}

sub RTE {
  my ($self,%args) = @_;
  return $self->Engine->RTE
    (
     Pairs => $args{Pairs},
    );
}

1;
