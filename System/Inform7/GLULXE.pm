package System::Inform7::GLULXE;

use PerlLib::SwissArmyKnife;

use Expect;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyExpect Debug /

  ];

our $doppleganger;

sub init {
  my ($self,%args) = @_;
  $doppleganger = $self;
  # $self->Debug(1);
}

sub Start {
  my ($self,%args) = @_;
  if (! defined $self->MyExpect) {
    $self->StartServer(%args);
  }
}

sub StartServer {
  my ($self,%args) = @_;
  my $command = '/var/lib/myfrdcsa/sandbox/glulxe-0.5.2/glulxe-0.5.2/glulxe';
  my @parameters = ($args{ULXFile});
  # print "$command ".join(' ', map {shell_quote($_)} @parameters)."\n";

  $self->MyExpect(Expect->new);
  $self->MyExpect->raw_pty(1);
  $self->MyExpect->log_stdout(0);
  print Dumper({CommandA => $command.' '.join(' ', @parameters)}) if $self->Debug;
  $self->MyExpect->spawn($command, @parameters)
    or die "Cannot spawn $command: $!\n";
  # print "Waiting for GLULXE to initialize...\n";
  $self->MyExpect->expect(300, [qr/./, sub {} ]);
  my $res = $self->MyExpect->match();
  print Dumper({ResA => $res}) if $self->Debug;
  $self->MyExpect->expect(300, [qr/^>$/m, sub {}]);
  $res .= $self->MyExpect->before();
  print Dumper({ResB => $res}) if $self->Debug;
  $self->MyExpect->clear_accum();
  return
    {
     Result => $res,
    };
}

sub StopServer {
  my ($self,%args) = @_;
  if ($args{HardRestart}) {
    $self->MyExpect->hard_close();
  } else {
    $self->MyExpect->soft_close();
  }
}

sub RestartServer {
  my ($self,%args) = @_;
  $self->StopServer
    (HardRestart => 1);
  $self->StartServer;
}

sub IssueCommand {
  my ($self,%args) = @_;
  my $command = $args{Command};
  # print "Issuing <$command>\n";
  print Dumper({CommandB => $command}) if $self->Debug;
  $self->MyExpect->print("$command\n");

  $self->MyExpect->expect(300, [qr/./, sub {} ]);
  my $res = $self->MyExpect->match();
  print Dumper({ResC => $res}) if $self->Debug;
  $self->MyExpect->expect(300, [qr/^>$/m, sub {}]);
  $res .= $self->MyExpect->before();
  print Dumper({ResD => $res}) if $self->Debug;
  if (! $res) {
    # timed out, restart server
    $self->RestartServer;
    print Dumper({Result => 'Fail'}) if $self->Debug;
    return {Fail => 1};
  } else {
    $self->MyExpect->clear_accum();
    # now extract the result
    return {Result => $self->ExtractResult(Text => $res)};
  }
}

sub ExtractResult {
  my ($self,%args) = @_;
  return $args{Text};
}

1;
