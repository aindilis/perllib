package Capability::CoreferenceResolution;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "BART";
  $self->Name($name);
  require "Capability/CoreferenceResolution/Engine/$name.pm";
  $self->Engine("Capability::CoreferenceResolution::Engine::$name"->new());
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

sub CoreferenceResolution {
  my ($self,%args) = @_;
  return $self->Engine->CoreferenceResolution(%args);
}

sub ReplaceCoreferences {
  my ($self,%args) = @_;
  return $self->Engine->ReplaceCoreferences(%args);
}

1;
