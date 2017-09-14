package Capability::NER;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "Stanford";
  $self->Name($name);
  require "Capability/NER/Engine/$name.pm";
  $self->Engine("Capability::NER::Engine::$name"->new());
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

sub NER {
  my ($self,%args) = @_;
  return $self->Engine->NER(Text => $args{Text});
}

sub NERExtract {
  my ($self,%args) = @_;
  return $self->Engine->NERExtract(Text => $args{Text});
}

1;
