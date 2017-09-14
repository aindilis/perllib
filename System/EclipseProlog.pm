package System::EclipseProlog;

use BOSS::Config;
use KBS2::ImportExport;
use PerlLib::ServerManager;
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyServerManager Regex Debug MyImportExport PreviousArgs /

  ];

sub init {
  my ($self,%args) = @_;
  $UNIVERSAL::eclipseprolog = $self;
  $self->PreviousArgs([]);
  $self->MyImportExport(KBS2::ImportExport->new);
  $self->Debug($args{Debug});
  $self->Regex(qr/^\[eclipse (\d+)\]: /sm);
}

sub StartServer {
  my ($self,%args) = @_;
  print Dumper({StartServerArgs => \%args});
  push @{$self->PreviousArgs}, \%args;
  my @commandparts = ('/var/lib/myfrdcsa/codebases/minor/eclipse-prolog/eclipse');
  if ($args{LoadFiles}) {
    push @commandparts, '-f '.join(' ',map {shell_quote($_)} @{$args{LoadFiles}});
  }
  my @goal;
  if ($args{Goals}) {
    push @goal, @{$args{Goals}};
  }
  if (@goal) {
    push @commandparts, '-e "'.join(',',@goal).'."';
  }
  my $command = join(' ',@commandparts);
  print $command."\n";
  $self->MyServerManager
    (
     PerlLib::ServerManager->new
     (
      Command => $command,
      Initialized => $self->Regex,
      Debug => $self->Debug,
     )
    );
  foreach my $file (@{$args{InitialFiles}}) {
    $self->ProcessInteraction(Query => "['$file'].");
  }
}

sub RestartServer {
  my ($self,%args) = @_;
  $self->MyServerManager->MyExpect->hard_close();
  # FIXME: change to a throw error
  die 'No previous StartServer Invocation' unless scalar @{$self->PreviousArgs};
  my %previousargs = %{$self->PreviousArgs->[-1]};
  $self->StartServer(%previousargs);
}

sub ProcessInteraction {
  my ($self,%args) = @_;
  $self->MyServerManager->MyExpect->print($args{Query}."\n");
  print "Submitting expect\n" if $self->Debug;
  $System::EclipseProlog::gotResult = 0;

  # # FIXME: add a handler for $self->ProcessInteraction(Query => "['$file'].");


  # # FIXME: generalize out FLUX/ALPProlog specific stuff here, move to their respective modules
  # # this is specific to FLUX
  # $self->MyServerManager->MyExpect->expect
  #   (5, [qr/(.+?)\s+(\[eclipse \d+\]: |There are \d+ delayed goals. Do you want to see them\? \(y\/n\))/sm, sub {$System::EclipseProlog::gotResult = 1; print "Got result\n";} ]);
  # my $res = $self->MyServerManager->MyExpect->match();
  # if ($res =~ /There are \d+ delayed goals. Do you want to see them\? \(y\/n\)/) {
  #   $res =~ s/\s+There are \d+ delayed goals. Do you want to see them\? \(y\/n\)//sg;
  #   $self->MyServerManager->MyExpect->print("n\n");
  #   $self->MyServerManager->MyExpect->expect
  #     (5, [qr/(.+?)\s+\[eclipse \d+\]: /sm, sub {$System::EclipseProlog::gotResult = 1; print "Got result\n";} ]);
  # } elsif (! $System::EclipseProlog::gotResult) {
  #   # FIXME: throw error
  #   # $self->RestartServer();
  # }

  # this is specific to ALPProlog
  $self->MyServerManager->MyExpect->expect
    (360, [qr/(.+?)\s+(\[eclipse \d+\]: |Yes \(\d+.\d+s cpu, solution \d+, maybe more\) \? )/sm, sub {$System::EclipseProlog::gotResult = 1; print "Got result\n";} ]);
  my $res = $self->MyServerManager->MyExpect->match();
  if ($res =~ /Yes \(\d+.\d+s cpu, solution \d+, maybe more\) \? /) {
    $res =~ s/Yes \(\d+.\d+s cpu, solution \d+, maybe more\) \? //sg;
    $self->MyServerManager->MyExpect->print("n\n");
    $self->MyServerManager->MyExpect->expect
      (5, [qr/(.+?)\s+\[eclipse \d+\]: /sm, sub {$System::EclipseProlog::gotResult = 1; print "Got result\n";} ]);
  } elsif (! $System::EclipseProlog::gotResult) {
    # FIXME: throw error
    # $self->RestartServer();
  }

  return $res;
}

1;
