package Capability::TextSummarization::Engine::MEAD;

use System::MEAD;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyMEAD /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyMEAD(System::MEAD->new);
}

sub StartServer {
  my ($self,%args) = @_;
  $self->MyMEAD->StartServer;
}

sub StopServer {
  my ($self,%args) = @_;
  $self->MyMEAD->StopServer;
}

sub StartClient {
  my ($self,%args) = @_;
}

sub StopClient {
  my ($self,%args) = @_;
}

sub SummarizeText {
  my ($self,%args) = @_;
  my $result = $self->MyMEAD->Summarize
    (Text => $args{Text});
  return {
	  Success => 1,
	  Result => $result,
	 };
}

1;
