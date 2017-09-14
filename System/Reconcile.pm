package System::Reconcile;

use PerlLib::Util;

use Data::Dumper;
use Expect;
use IO::File;
use File::Temp qw(tempfile tempdir);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyProcessString MyExpect Debug /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyProcessString("java -Xmx1024m elkfed.webdemo.BARTServer");
  $self->Debug($args{Debug} || 0);
}

sub StartServer {
  my ($self,%args) = @_;
  if (! $self->AlreadyRunning and ! defined $self->MyExpect) {
    $self->StartBART(%args);
  }
}

sub StartBART {
  my ($self,%args) = @_;
  $self->MyExpect(Expect->new);
  $self->MyExpect->raw_pty(1);
  $self->MyExpect->log_stdout($self->Debug);
  my @parameters;
  my $command = "cd /var/lib/myfrdcsa/sandbox/reconcile-20100208/reconcile-20100208 && ant run";
  print "$command\n";
  $self->MyExpect->spawn($command, @parameters);
  $self->MyExpect->expect(300, [qr/done \[[\d\.]+ sec\]./, sub {print "\nInitialized.\n\n"}]);
  $self->MyExpect->clear_accum();
}

sub AlreadyRunning {
  my ($self,%args) = @_;
  my $item = PidsForProcess
    (Process => $self->MyProcessString);
  return scalar @$item;
}

sub StopServer {
  my ($self,%args) = @_;
  KillProcesses
    (Process => $self->MyProcessString);
}

sub CoreferenceResolution {
  my ($self,%args) = @_;

}

1;
