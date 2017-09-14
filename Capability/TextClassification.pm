package Capability::TextClassification;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "Advanced";
  $self->Name($name);
  require "Capability/TextClassification/$name.pm";
  $self->Engine("Capability::TextClassification::$name"->new());
}

sub StartServer {
  my ($self,%args) = @_;
  $self->Engine->StartServer
    (%args);
}

sub StartClient {
  my ($self,%args) = @_;
  $self->Engine->StartClient
    (%args);
}

sub AddInstance {
  my ($self,%args) = @_;
  return $self->Engine->AddInstance
    (%args);
}

sub Train {
  my ($self,%args) = @_;
  return $self->Engine->Train
    (%args);
}

sub TrainTest {
  my ($self,%args) = @_;
  return $self->Engine->TrainTest
    (%args);
}

sub Classify {
  my ($self,%args) = @_;
  return $self->Engine->Classify
    (%args);
}

1;
