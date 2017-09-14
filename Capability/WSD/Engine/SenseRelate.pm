package Capability::WSD::Engine::SenseRelate;

use Data::Dumper;
use PerlLib::WSD;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Server Client /

  ];

sub init {
  my ($self,%args) = @_;
}

sub StartServer {
  my ($self,%args) = @_;
  if (! defined $self->Server) {
    $self->Server
      (PerlLib::WSD->new());
  }
}

sub StartClient {
  my ($self,%args) = @_;
}

sub WQD {
  my ($self,%args) = @_;
  return $self->Server->WQD(WQD => $args{WQD});
}

sub ProcessText {
  my ($self,%args) = @_;
  $self->Server->ProcessText
    (Text => $args{Text});
}

sub ProcessSentence {
  my ($self,%args) = @_;
  $self->Server->ProcessSentence
    (Sentence => $args{Sentence});
}

1;
