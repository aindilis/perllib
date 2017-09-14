package System::FactualStatementExtractor;

# STATUS

# Need to also add an agent for this:

use BOSS::Config;
use Formalize2::UniLang::Client;
use KBS2::ImportExport;
use PerlLib::Sentence;
use PerlLib::ServerManager;
use PerlLib::SwissArmyKnife;
use Sayer;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config Conf MyServerManager1 MyServerManager2 Regex MyFormalize Debug
   MyImportExport MySayer Inits Codes HasBeenInitialized MySentence
   Overwrite /

  ];

sub init {
  my ($self,%args) = @_;
  my $specification = q(
	-f <file>	List existing searches
	-c		Clear the Sayer Cache
	-d		Debug
	-s <method>	Split by method ("section","every few sentences")
	-o		Overwrite the cached results for this

	--no-formalize	Skip formalization step

);
  $self->Config
    (BOSS::Config->new
     (Spec => $specification));
  $self->Conf($self->Config->CLIConfig);
  # $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/free-knext";
  $self->Debug($self->Conf->{'-d'});
  $self->HasBeenInitialized({});
  $self->Regex
    (qr/Waiting for Connection on Port: 5556/sm);
  $self->MySentence
    (
     PerlLib::Sentence->new,
    );
  $self->MySayer
    ($args{Sayer} ||
     Sayer->new
     (
      DBName => "sayer_generic",
      Debug => $self->Debug,
     ));
  $self->Inits
    ({
      FactualStatementExtractor => sub {
	my $self = shift;
	$self->MyServerManager1
	  (
	   PerlLib::ServerManager->new
	   (
	    Command => "cd /var/lib/myfrdcsa/sandbox/factualstatementextractor-20100626/factualstatementextractor-20100626 && ./runStanfordParserServer.sh",
	    Initialized => $self->Regex,
	    Verbose => 1,
	   )
	  );
      },
     });
  $self->Codes
    ({
      FactualStatementExtractor => sub {
	my %args = %{$_[0]};
	my $self = $UNIVERSAL::factualstatementextractor || $UNIVERSAL::genericagentobject;
	return $self->FactualStatementExtractorSayer(Sentence => $args{Sentence});
      },
     });
  $self->MyFormalize
    (Formalize2::UniLang::Client->new) unless $self->Conf->{'--no-formalize'};
  $self->MyImportExport
    (KBS2::ImportExport->new);
  if (1 or exists $self->Conf->{'-o'}) {
    $self->Overwrite(1);
  } else {
    $self->Overwrite(0);
  }
}

sub StartServer {
  my ($self,%args) = @_;
  if (! exists $self->HasBeenInitialized->{FactualStatementExtractor}) {
    print "Initializing $key\n";
    if (exists $self->Inits->{FactualStatementExtractor}) {
      &{$self->Inits->{FactualStatementExtractor}}($self);
    }
    $self->HasBeenInitialized->{FactualStatementExtractor} = 1;
  }
  if (! defined $self->MyServerManager2) {
    $self->MyServerManager2
      (
       PerlLib::ServerManager->new
       (
	Command => "cd /var/lib/myfrdcsa/sandbox/factualstatementextractor-20100626/factualstatementextractor-20100626 && ./simplify.sh",
	# Debug => 1,
       )
      );
  }
}

sub FactualStatementExtractor {
  my ($self,%args) = @_;
  my @allresults;
  foreach my $sentence
    (@{$self->MySentence->GetSentences
	 (
	  Text => $args{Text},
	  Clean => 1,
	 )}) {
    my @result = $self->MySayer->ExecuteCodeOnData
      (
       Overwrite => $self->Overwrite,
       CodeRef => $self->Codes->{FactualStatementExtractor},
       Data => [{
		 Sentence => $sentence,
		}],
      );
    my $res = shift @result;
    if ($res->{Success}) {
      push @allresults, $res->{Result};
    }
  }
  return {
	  Success => 1,
	  Result => \@allresults,
	 };
}

sub FactualStatementExtractorSayer {
  my ($self,%args) = @_;
  # print the sentence and then parse it
  print "hello there!\n";
  my $regex = qr/.*Seconds Elapsed:\s+([\d\.]+)/sm;
  my $command = $args{Sentence};
  print Dumper({Command => $command});
  # make sure it's on one line
  $self->MyServerManager2->MyExpect->print
    ($command."\n");
  $self->MyServerManager2->MyExpect->expect
    (60, [$regex]);
  my $res = $self->MyServerManager2->MyExpect->match();
  print Dumper({Res1 => $res});
  $res =~ s/^.*INFO: Installing dictionary net.didion.jwnl.dictionary.FileBackedDictionary[^\r\n]+[\n\r]//s;
  $res =~ s/\nSeconds Elapsed:\s+([\d\.]+)$//sm;
  print Dumper({Res => $res});
  print Dumper({Accum => $self->MyServerManager2->MyExpect->clear_accum()});
  return {
	  Success => 1,
	  Result => [split /\n/, $res],
	 };
}

1;
