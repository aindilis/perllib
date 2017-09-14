package System::FLUX;

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

sub LoadFluxFiles {
  my ($self,%args) = @_;
  my (%newargs);
  if ($args{FluxFile}) {
    $newargs{LoadFiles} = [$args{FluxFile}];
  }
  if ($args{FluxDomain} or $args{FluxProblem}) {
    $newargs{InitialFiles} = [$args{FluxDomain},$args{FluxProblem}];
  }
  if ($args{FluxGoal}) {
    $newargs{Goals} = [$args{FluxGoal}];
  }
  $self->MyEclipseProlog->StartServer(%newargs);
}

sub Plan {
  my ($self,%args) = @_;
  my $res1 = $self->ProcessInteraction(Query => 'main.');
  print Dumper({Res1 => $res1});
  if ($res1 =~ /^\[plan, (.+?)\]$/mg) {
    my $plan = $1;
    print "plan: <$plan>\n";
    my $res2 = $self->MyImportExport->Convert
      (
       Input => $plan.'.',
       InputType => 'Prolog',
       OutputType => 'SWIPL',
      );
    $res2->{Prolog} = $plan;
    return $res2;
  }
}

sub Test {
  my ($self,%args) = @_;
  $self->LoadFluxFiles
    (
     FluxFile => '6_nursebot_canonical.pl',
     FluxDomain => '6_nursebot_domain.pl',
     FluxProblem => '6_nursebot_problem.pl',
    );

  print Dumper({Res => [$self->Plan()]});
}

1;
