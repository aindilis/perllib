package Capability::TextSummarization;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "LinguaENSummarize";
  $self->Name($name);
  require "Capability/TextSummarization/Engine/$name.pm";
  $self->Engine("Capability::TextSummarization::Engine::$name"->new());
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

sub SummarizeText {
  my ($self,%args) = @_;
  return $self->Engine->SummarizeText
    (%args);
}

1;
