package System::BART;

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
  my @parameters = ();
  # my $command = "cd /var/lib/myfrdcsa/sandbox/bart-20091005/bart-20091005/BART-snapshot/BART && source setup.sh && java -Xmx1024m elkfed.webdemo.BARTServer";
  my $command = "/var/lib/myfrdcsa/codebases/internal/perllib/scripts/start-bart.sh";
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
  $self->MyExpect->expect(0.1,[ qr/.+/s => sub { print "Clearing\n"; } ]);
  print Dumper({ResolutionArgs => \%args});
  my $tf = File::Temp->new;
  my $fn = $tf->filename;
  my $fh = IO::File->new
    (">$fn");
  $fh->print($args{Text});
  my $result = `cat $fn | POST http://localhost:8125/BARTDemo/ShowText/process/`;
  $fh->close;
  $self->MyExpect->expect(0.1,[ qr/.+/s => sub { print "Clearing\n"; } ]);
  return $result;
}

1;
