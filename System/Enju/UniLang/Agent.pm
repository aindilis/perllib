package System::Enju::UniLang::Agent;

use BOSS::Config;
use Manager::Dialog qw(Message QueryUser);
use MyFRDCSA;
use System::Enju;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => 
  [ qw /

	Config MyEnju

	/ ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	-u [<host> <port>]	Run as a UniLang agent
";
  $UNIVERSAL::agent->DoNotDaemonize(1);
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"perllib","scripts","agents");
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }
  $self->MyEnju
    (System::Enju->new
     ());
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    # enter in to a listening loop
    while (1) {
      $UNIVERSAL::agent->Listen(TimeOut => 10);
    }
  }
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};
  my $it = $m->Contents;
  if ($it) {
    if ($it =~ /^(quit|exit)$/i) {
      $UNIVERSAL::agent->Deregister;
      exit(0);
    } elsif ($it =~ /^echo\s*(.*)/) {
      $UNIVERSAL::agent->SendContents
	(Contents => $1,
	 Receiver => $m->Sender);
    } elsif ($it =~ /^process\s*(.*)/) {
      return $UNIVERSAL::agent->QueryAgentReply
	(
	 Message => $m,
	 Contents => Dumper($self->MyEnju->ApplyEnjuToText(Text => $1)),
	);
    }
  }
  if (exists $m->Data->{_RPC_Sub}) {
    my $rpc_sub = $m->Data->{_RPC_Sub};
    my $sub = eval "sub {\$self->MyEnju->$rpc_sub(\@_)}";
    $UNIVERSAL::agent->QueryAgentReply
      (
       Message => $m,
       Data => {
		_DoNotLog => 1,
		_RPC_Results => [$sub->(@{$m->Data->{_RPC_Args}})],
	       },
      );
  } else {
    if ($m->Data->{Start}) {
      # okay it is started, just check about the fast
      # okay
      $self->MyEnju->StartEnju
	(
	 Fast => $m->Data->{Fast},
	);
      $UNIVERSAL::agent->QueryAgentReply
	(
	 Message => $m,
	 Data => {
		  _DoNotLog => 1,
		  Result => {
			     Success => 1,
			    },
		 },
	);
    }
  }
}

1;
