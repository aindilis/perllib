package Capability::CoreferenceResolution::UniLang::Client;

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
      RandName => "CoreferenceResolution-Client",
     ));
  $self->Version
    ($args{Version});
  $self->Receiver
    ($args{Receiver} || "CoreferenceResolution");
}

sub StartServer {
  my ($self,%args) = @_;
  my $m = $self->MyTempAgent->MyAgent->QueryAgent
    (
     Receiver => "CoreferenceResolution",
     Data => {
	      Start => 1,
	     },
    );
}

sub StopServer {
  my ($self,%args) = @_;
  $self->MyTempAgent->Send
    (
     Contents => "CoreferenceResolution, quit",
    );
}

sub RestartServer {
  my ($self,%args) = @_;
  $self->StopServer();
  $self->StartServer();
}

sub CoreferenceResolution {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "CoreferenceResolution",
     _RPC_Args => [%args],
    );
  return $res[0];
}

sub ReplaceCoreferences {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "ReplaceCoreferences",
     _RPC_Args => [%args],
    );
  return $res[0];
}

1;
