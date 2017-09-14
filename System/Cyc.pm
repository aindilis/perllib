package System::Cyc;

# $UNIVERSAL::debug = 1;

use BOSS::Config;
use KBS2::ImportExport;
use KBS2::Util;
use MyFRDCSA qw(Dir);
use PerlLib::SwissArmyKnife;
use System::Cyc::Java::CycAccess;
use System::Cyc::Exception;
use UniLang::Util::Message;

use Moose;
use Inline::Java qw(caught);
use Try::Tiny;

has Host => (is => 'rw', isa => 'Str', default => "localhost");
has Port => (is => 'rw', isa => 'Int', default => "3614");
# has Port => (is => 'rw', isa => 'Int', default => "3674");
has LogFile => (is => 'rw', isa => 'Str', default => "/var/lib/myfrdcsa/codebases/minor/cyc-common/data-git/logs/cyc-log-".DateTimeStamp().".subl");
has Log => (is => 'rw', isa => 'IO::File');
has Prompt => (is => 'rw', isa => 'Str', default => "> ");
has Cyc => (is => 'rw', isa => 'System::Cyc::Java::CycAccess');
has Mt => (is => 'rw', isa => 'Str');
has ImportExport => (is => 'rw', isa => 'KBS2::ImportExport', default => sub { KBS2::ImportExport->new });

has Config => (is => 'rw', isa => 'BOSS::Config');
# has Debug => (is => 'rw', isa => 'Bool', default => 1);

# $UNIVERSAL::debug = 1;

sub BUILD {
  my ($self,%args) = (shift,%{$_[0]});
  my $specification = "
	-u [<host> <port>]	Run as a UniLang agent
";
  if (defined $UNIVERSAL::agent) {
    $UNIVERSAL::agent->DoNotDaemonize(1);
  }
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"perllib");
  # $UNIVERSAL::debug = 1;
  $self->Config
    (BOSS::Config->new
     (Spec => $specification,
      ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    if (defined $UNIVERSAL::agent) {
      $UNIVERSAL::agent->Register
	(Host => defined $conf->{-u}->{'<host>'} ?
	 $conf->{-u}->{'<host>'} : "localhost",
	 Port => defined $conf->{-u}->{'<port>'} ?
	 $conf->{-u}->{'<port>'} : "9000");
    }
  }
}

sub StartServer {
  # my ($self,%args) = @_;
  # make sure cyc server is running
  # NotYetImplemented();
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    # enter in to a listening loop
    while (1) {
      if (defined $UNIVERSAL::agent) {
	$UNIVERSAL::agent->Listen(TimeOut => 10);
      }
    }
  }
}

sub StartLogUnlessAlreadyRunning {
  my ($self,%args) = @_;
  if (! defined $self->Log) {
    my $LOG = IO::File->new();
    $LOG->open(">>".$self->LogFile) or
      throw Error "Cannot open logfile: ".$self->LogFile;
    $self->Log($LOG);
  }
}

sub LogToFile {
  my ($self,%args) = @_;
  $self->StartLogUnlessAlreadyRunning;
  my $LOG = $self->Log;
  print $LOG $args{Message};
  $LOG->flush();
}

sub Connect {
  my ($self,%args) = @_;
  $self->StartLogUnlessAlreadyRunning;
  try {
    $self->Cyc
      (System::Cyc::Java::CycAccess->new
       (
	Host => $args{Host} || $self->Host,
	Port => $args{Port} || $self->Port,
	User => $args{User},
	CycKE => $args{CycKE},
       ));
    print Dumper({Cyc => $self->Cyc}) if $UNIVERSAL::debug;
  } catch {
    throw Error::Simple("Cannot open connection to ".$self->Host." ".$self->Port);
  };
  print "Finished attempting to connect\n" if $UNIVERSAL::debug;
}

sub Disconnect {
  my ($self,%args) = @_;
  $self->Log->Close();
  # $self->Cyc->FIXMEHowToClose();
}

sub MyQuote {
  my (%args) = @_;
  DumperQuote2(\%args).",\n";
}

sub CycLQuery {
  my ($self,%args) = @_;
  $self->LogToFile(Message => MyQuote(%args));

  defined $args{CycLQuery} or System::Cyc::Exception->throw(msg => "Require CycLQuery Param");

  my $cyclist;
  try {
    $cyclist = $self->Cyc->makeCycList($args{CycLQuery});
  }
    catch {
      $self->SeeException($_);
    };

  defined $args{Mt} or System::Cyc::Exception->throw(msg => "Require Mt Param");
  my $mt;
  try {
    $mt = $self->Cyc->getKnownConstantByName($args{Mt} || $self->Mt);
  }
    catch {
      $self->SeeException($_);
    };

  my $properties;
  try {
    $properties = $self->Cyc->createInferenceParams();
  }
    catch {
      $self->SeeException($_);
    };

  my $result;
  try {
    $result = $self->Cyc->askNewCycQuery($cyclist, $mt, $properties);
  }
    catch {
      $self->SeeException($_);
    };

  if (defined $result) {
    if ($args{OutputType} eq 'Interlingua') {
      my @result;
      my $e1 = $result->listIterator(0);
      while ($e1->hasNext()) {
	my $o1 = $e1->next();
	my $type = ref($o1);
	if ($type =~ /System::Cyc::(Open|Research|Enterprise)Cyc::Java::CycAccess::org::opencyc::cycobject::CycList/) {
	  push @result,
	    [
	     Var($o1->first()->first()->toString),
	     $o1->first()->rest()->cyclify(),
	    ];
	} else {
	  System::Cyc::Exception->throw
	      (msg => "Do not know how to handle type: <$type>");
	}
      }
      return {
	      Result => \@result,
	     };
    }
  }
}

sub ConverseObject {
  my ($self,%args) = @_;
  # print "hello\n";

  my $access = $self->Cyc;

  my $output;
  my $result;
  my $res;
  try {
    # i.e. SubL => '(new-cyc-query \'(#$isa ?X #$Dog) #$EverythingPSC)'
    $result = $access->converseObject($args{SubL});
    if ($args{OutputType} eq 'Interlingua') {
      my $ref = ref($result);
      if ($ref =~ /^System::Cyc::(OpenCyc|ResearchCyc(1_0)?|EnterpriseCyc)::Java::(CycLParserUtil|CycAccess)::org::opencyc::cycobject/) {
	$res = $self->ImportExport->Convert
	  (
	   Input => $result,
	   InputType => 'ResearchCycAPI',
	   OutputType => 'Interlingua',
	  );
	if (! $res->{Success}) {
	  System::Cyc::Exception->throw
	      (msg => "Cannot convert to Interlingua from OpenCycAPI <".Dumper($res).">");
	} else {
	  $output = $res->{Output};
	}
      } else {
	$output = $result;
      }
    }
  } catch {
   System::Cyc::Exception->throw($self->SeeException($_));
  };
  return $output;
}

sub Loop {
  my ($self,%args) = @_;
  print $self->Prompt;
  my $cmd;
  my $LOG = $self->Log;
  while (defined ($cmd = <>) && ($cmd !~ /^(quit|exit)$/)) {
    if ($cmd =~ /^Mt: (.+?)$/) {
      $self->Mt($1);
    } elsif ($cmd !~ /^$/) {
      print LOG "$cmd";
      LOG->autoflush(1);
      my $res = $self->Query
	(
	 Query => $cmd,
	 Mt => $self->Mt,
	);
    }
    print $self->Prompt;
  }
  $self->Disconnect;
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};
  print Dumper($m) if $UNIVERSAL::debug;
  my $it = $m->Contents;
  if ($it) {
    if ($it =~ /^(quit|exit)$/i) {
      $UNIVERSAL::agent->Deregister;
      exit(0);
    } elsif ($it =~ /^connect$/) {
      $self->TryToConnect(Message => $m);
    } elsif ($it =~ /^subl-query (.+)?$/) {
      $m->{Data}{SubLQuery} = $1;
      $self->ProcessSubLQuery(Message => $m);
    } elsif ($it =~ /^echo\s*(.*)/) {
      $UNIVERSAL::agent->SendContents
	(Contents => $1,
	 Receiver => $m->Sender);
    }
  }
  if (exists $m->{Data}{StartServer}) {
    $self->StartServer();
    $UNIVERSAL::agent->QueryAgentReply
      (
       Message => $m,
       Data => {
		_DoNotLog => 1,
		Result => 'started',
	       },
	);
  }
  if (exists $m->{Data}{Connect}) {
    $self->TryToConnect(Message => $m);
  }
  if (exists $m->{Data}{Disconnect}) {
    $self->Disconnect();
    $UNIVERSAL::agent->QueryAgentReply
      (
       Message => $m,
       Data => {
		_DoNotLog => 1,
		Result => 'connected',
	       },
	);
  }
  if (exists $m->{Data}{CycLQuery}) {
    $self->ProcessCycLQuery(Message => $m);
  }
  if (exists $m->{Data}{SubLQuery}) {
    # print "Davee\n";
    $self->ProcessSubLQuery(Message => $m);
  }
}

sub ProcessCycLQuery {
  my ($self,%args) = @_;
  $self->LogToFile(Message => MyQuote(%args));
  my $m = $args{Message};
  if (exists $m->{Data}{CycLQuery}) {
    my $res;
    try {
      $res = $self->CycLQuery
	(
	 CycLQuery => $m->{Data}{CycLQuery},
	 Mt => $m->{Data}{Mt},
	);
      $self->LogToFile(Message => MyQuote(Result => $res));
      $UNIVERSAL::agent->QueryAgentReply
	(
	 Message => $m,
	 Data => {
		  _DoNotLog => 1,
		  Result => $res,
		 },
	);
    }
      catch {
	my $exception = $_;
	my $errormsg = $self->SeeException($exception, String => 1);
	$UNIVERSAL::agent->QueryAgentReply
	  (
	   Message => $m,
	   Data => {
		    _DoNotLog => 1,
		    Error => 1,
		    ErrorMsg => $errormsg,
		   },
	  );
	warn $errormsg;
      };
  } else {
    $UNIVERSAL::agent->QueryAgentReply
      (
       Message => $m,
       Data => {
		_DoNotLog => 1,
		Error => 1,
		ErrorMsg => 'E: Unknown Command',
	       },
      );
  }
}

sub ProcessSubLQuery {
  my ($self,%args) = @_;
  $self->LogToFile(Message => MyQuote(%args));
  my $m = $args{Message};
  if (exists $m->{Data}{SubLQuery}) {
    my $res;
    print Dumper({M => $m}) if $UNIVERSAL::debug;
    try {
      $res = $self->ConverseObject
	(
	 User => $args{User},
	 CycKE => $args{CycKE},
	 SubL => $m->{Data}{SubLQuery},
	 OutputType => $m->{Data}{OutputType} || 'Interlingua',
	);
      $self->LogToFile(Message => MyQuote(Result => $res));
      $UNIVERSAL::agent->QueryAgentReply
	(
	 Message => $m,
	 Data => {
		  _DoNotLog => 1,
		  Result => $res,
		 },
	);
    }
      catch {
	my $exception = $_;
	my $errormsg = $self->SeeException($exception, String => 1);
	$UNIVERSAL::agent->QueryAgentReply
	  (
	   Message => $m,
	   Data => {
		    _DoNotLog => 1,
		    Error => 1,
		    ErrorMsg => $errormsg,
		   },
	  );
	warn $errormsg;
      };
  } else {
    $UNIVERSAL::agent->QueryAgentReply
      (
       Message => $m,
       Data => {
		_DoNotLog => 1,
		Error => 1,
		ErrorMsg => 'E: Unknown Command',
	       },
      );
  }
}

sub SeeException {
  print Dumper(\@_) if $UNIVERSAL::debug;
  my ($self,$exception,%args) = @_;
  my %hash = ();
  if ( blessed $exception ) {
    if ( $exception->can('toString') ) {
      $hash{msg} = $exception->toString;
    } elsif ( $exception->can('msg') ) {
      $hash{msg} = $exception->msg;
    }
    if ( $exception->can('rethrow') ) {
      $hash{rethrowable} = $exception,
    }
  } else {
    $hash{msg} = Dumper($exception);
  }
  if (defined $args{Warn}) {
    warn $hash{msg};
  } elsif (defined $args{String}) {
    warn $hash{msg};
  } else {
    print Dumper({Throwing =>  \%hash});
    System::Cyc::Exception->throw(%hash);
  }
  return $hash{msg};
}

sub TryToConnect {
  my ($self,%args) = @_;
  my $m = $args{Message};
  if (defined $self->Cyc) {
    if (! $self->Cyc->isClosed) {
      $UNIVERSAL::agent->QueryAgentReply
	(
	 Message => $m,
	 Data => {
		  _DoNotLog => 1,
		  Result => 'connected',
		 },
	);
      return;
    }
  }
  try {
    my %cycargs = %{exists $m->{Data}{CycArgs} ? $m->{Data}{CycArgs} : {}};
    $self->Connect(%cycargs);
    $UNIVERSAL::agent->QueryAgentReply
      (
       Message => $m,
       Data => {
		_DoNotLog => 1,
		Result => 'connected',
	       },
      );
  } catch {
    print "ERROR: Could not connect to *Cyc\n";
    $UNIVERSAL::agent->QueryAgentReply
      (
       Message => $m,
       Data => {
		_DoNotLog => 1,
		Result => 'not connected',
	       },
      );
  };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
