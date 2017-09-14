package System::Enju::UniLang::Client;

# use Manager::Dialog qw(QueryUser);
use UniLang::Util::TempAgent;

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyTempAgent Version Receiver /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyTempAgent
    (UniLang::Util::TempAgent->new
     (
      RandName => "Enju-Client",
     ));
  $self->Version
    ($args{Version});
  $self->Receiver
    ($args{Receiver} || "Enju");
}

sub StartEnju {
  my ($self,%args) = @_;
  my $m = $self->MyTempAgent->MyAgent->QueryAgent
    (
     Receiver => "Enju",
     Data => {
	      Start => 1,
	      Fast => 1,
	     },
    );
}

sub StopServer {
  my ($self,%args) = @_;
  $self->MyTempAgent->Send
    (
     Contents => "Enju, quit",
    );
}

sub RestartServer {
  my ($self,%args) = @_;
  $self->StopServer();
  $self->StartServer();
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

sub ApplyEnjuToSentence {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "ApplyEnjuToSentence",
     _RPC_Args => [%args],
    );
  return $res[0];
}

sub ApplyEnjuToText {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "ApplyEnjuToText",
     _RPC_Args => [%args],
    );
  return $res[0];
}

sub ApplyEnjuToFile {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "ApplyEnjuToFile",
     _RPC_Args => [%args],
    );
  return $res[0];
}

1;
