package PerlLib::ServerManager::UniLang::Agent;

use BOSS::Config;
use Manager::Dialog qw(Message QueryUser);
use MyFRDCSA;
use PerlLib::SwissArmyKnife;

use Try::Tiny;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => 
  [

   qw / Config MyObject AgentName ModuleName ModuleFile Debug /

  ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	-u [<host> <port>]	Run as a UniLang agent
";
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"perllib","scripts","agents");
  $self->Config($args{Config});
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }
  # we need to eval the object

  $self->AgentName
    ($args{AgentName});
  $self->ModuleName
    ($args{ModuleName});
  $self->ModuleFile
    ($args{ModuleFile});
}

sub LoadObject {
  my ($self,%args) = @_;
  # do the require
  # print Dumper([$self->ModuleFile,$self->ModuleName]);
  eval "require \"".$self->ModuleFile."\";";
  my $statement = "\$UNIVERSAL::genericagentobject = ".$self->ModuleName."->new();";
  print $statement."\n";
  my $object = eval $statement;
  # print Dumper($object);
  $self->MyObject
    ($object);
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
  my $doobjectprocessmessage = 0;
  print Dumper({M => $m}) if $self->Debug;
  my $it = $m->Contents;
  if ($it) {
    if ($it =~ /^(quit|exit)$/i) {
      $UNIVERSAL::agent->Deregister;
      exit(0);
    } elsif ($it =~ /^echo\s*(.*)/) {
      $UNIVERSAL::agent->SendContents
	(
	 Contents => $1,
	 Receiver => $m->Sender,
	);
    } else {
      $doobjectprocessmessage = 1;
    }
  }
  if (exists $m->Data->{_RPC_Sub}) {
    my $rpc_sub = $m->Data->{_RPC_Sub};
    print Dumper
      ({
	Object => $self->MyObject,
	Sub => $rpc_sub,
       }) if $self->Debug;
    my $string = "sub {\$self->MyObject->$rpc_sub(\@_)}";
    print SeeDeeply({String => $string});
    my $sub = eval $string;
    my @res = $sub->(@{$m->Data->{_RPC_Args}});
    $UNIVERSAL::agent->QueryAgentReply
      (
       Message => $m,
       Data => {
		_DoNotLog => 1,
		_RPC_Results => \@res,
		# _Exception => $exception,
	       },
      );
  } else {
    if ($m->Data->{StartServer}) {
      # okay it is started, just check about the fast
      # okay
      $self->MyObject->StartServer
	(
	 %{$m->Data->{Args}},
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
    } else {
      $doobjectprocessmessage = 1;
    }
  }
  if ($doobjectprocessmessage and $self->MyObject->can('ProcessMessage')) {
    $self->MyObject->ProcessMessage
      (
       Message => $m,
      );
  }
}

sub StartServer {
  my ($self,%args) = @_;
  $self->MyObject->StartServer
    (
     %args,
    );
}

1;
