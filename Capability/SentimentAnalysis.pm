package Capability::SentimentAnalysis;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "CAndC";
  $self->Name($name);
  require "Capability/SentimentAnalysis/$name.pm";
  $self->Engine("Capability::SentimentAnalysis::$name"->new());
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

sub SentimentAnalysis {
  my ($self,%args) = @_;
  return $self->Engine->SentimentAnalysis
    (Text => $args{Text});
}

1;
