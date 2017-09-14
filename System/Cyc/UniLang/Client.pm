package System::Cyc::UniLang::Client;

use UniLang::Util::TempAgent;

use Data::Dumper;

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
      RandName => "Cyc-Client",
     ));
  $self->Version
    ($args{Version});
  $self->Receiver
    ($args{Receiver} || "Cyc");
}

sub StartCyc {
  my ($self,%args) = @_;
  my $m = $self->MyTempAgent->MyAgent->QueryAgent
    (
     Receiver => "Cyc",
     Data => {
	      Start => 1,
	     },
    );
}

sub StopServer {
  my ($self,%args) = @_;
  $self->MyTempAgent->Send
    (
     Contents => "Cyc, quit",
    );
}

sub RestartServer {
  my ($self,%args) = @_;
  $self->StopServer();
  $self->StartServer();
}

sub Query {
  my ($self,%args) = @_;
  my @res = $self->MyTempAgent->RPC
    (
     Receiver => $self->Receiver,
     _RPC_Sub => "Query",
     _RPC_Args => [%args],
    );
  return $res[0];
}

1;
