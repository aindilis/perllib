package Capability::SpeechActClassification;

use MyFRDCSA;
use System::Semanta;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MySemanta /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MySemanta(System::Semanta->new);
}

sub StartServer {
  my ($self,%args) = @_;
  # $self->MySemanta->StartServer(%args);
}

sub StopServer {
  my ($self,%args) = @_;
  # $self->MySemanta->StopServer(%args);
}

sub GetSpeechActs {
  my ($self,%args) = @_;
  return $self->MySemanta->GetSpeechActs(%args);
}

1;
