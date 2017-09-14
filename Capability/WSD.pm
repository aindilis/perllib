package Capability::WSD;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  my $name = $args{EngineName} || "SenseRelate";
  $self->Name($name);
  require "Capability/WSD/Engine/$name.pm";
  $self->Engine("Capability::WSD::Engine::$name"->new());
}

sub StartServer {
  my ($self,%args) = @_;
  $self->Engine->StartServer;
}

sub StartClient {
  my ($self,%args) = @_;
  $self->Engine->StartClient;
}

sub ProcessText {
  my ($self,%args) = @_;
  return $self->Engine->ProcessText(Text => $args{Text});
}

sub WQD {
  my ($self,%args) = @_;
  return $self->Engine->WQD(WQD => $args{WQD});
}

sub ProcessSentence {
  my ($self,%args) = @_;
  return $self->Engine->ProcessSentence(Sentence => $args{Sentence});
}

1;
