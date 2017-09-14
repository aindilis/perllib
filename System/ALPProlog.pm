package System::ALPProlog;

use BOSS::Config;
use KBS2::ImportExport;
use PerlLib::ServerManager;
use PerlLib::SwissArmyKnife;
use System::EclipseProlog;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyEclipseProlog MyImportExport /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyEclipseProlog(System::EclipseProlog->new);
  $self->MyImportExport(KBS2::ImportExport->new);
}

sub ProcessInteraction {
  my ($self,%args) = @_;
  $self->MyEclipseProlog->ProcessInteraction(%args);
}

sub LoadALPPrologFiles {
  my ($self,%args) = @_;
  my (%newargs);
  if ($args{ALPPrologFile}) {
    $newargs{LoadFiles} = [$args{ALPPrologFile}];
  }
  if ($args{ALPPrologDomain} or $args{ALPPrologProblem}) {
    $newargs{InitialFiles} = [$args{ALPPrologDomain},$args{ALPPrologProblem}];
  }
  if ($args{ALPPrologGoal}) {
    $newargs{Goals} = [$args{ALPPrologGoal}];
  }
  $self->MyEclipseProlog->StartServer(%newargs);
}

sub Plan {
  my ($self,%args) = @_;
  my $res1 = $self->ProcessInteraction(Query => 'main.');
  # if ($res1 =~ /^\[plan, (.+?)\]$/mg) {
  # my $plan = $1;
  my $plan = $res1;
  print "plan: <$plan>\n";
  my $res2 = {}; # $self->MyImportExport->Convert
    # (
    #  Input => $plan.'.',
    #  InputType => 'Prolog',
    #  OutputType => 'SWIPL',
    # );
  $res2->{Prolog} = $plan;
  return $res2;
  # }
}

sub Test {
  my ($self,%args) = @_;
  $self->LoadALPPrologFiles
    (
     ALPPrologFile => 'wumpus_strategy.ecl',
     # ALPPrologFile => '6_nursebot_canonical.pl',
     # ALPPrologDomain => '6_nursebot_domain.pl',
     # ALPPrologProblem => '6_nursebot_problem.pl',
    );

  print Dumper({Res => [$self->Plan()]});
}

1;
