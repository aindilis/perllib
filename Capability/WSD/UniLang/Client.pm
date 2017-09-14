package Capability::WSD::UniLang::Client;

use UniLang::Util::TempAgent;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyTempAgent Receiver Name Engine /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyTempAgent
    (UniLang::Util::TempAgent->new
     ());
  $self->Receiver("WSD");
}

sub StartServer {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "StartServer",
     _RPC_Args => [%args],
    );
  return $res[0];
}

sub StartClient {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "StartClient",
     _RPC_Args => [%args],
    );
  return $res[0];
}

sub ProcessText {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "ProcessText",
     _RPC_Args => [%args],
    );
  return $res[0];
}

sub ProcessSentence {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "ProcessSentence",
     _RPC_Args => [%args],
    );
  return $res[0];
}

1;
