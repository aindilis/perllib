package System::MEAD;

use Data::Dumper;
use File::Temp qw(tempfile tempdir);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;
  $ENV{BINPATH} = "/var/lib/myfrdcsa/sandbox/mead-3.12/mead-3.12/bin";
}

sub Summarize {
  my ($self,%args) = @_;
  return unless $args{Text};
  if (! $self->ServerRunning) {
    $self->StartServer;
  }
  my $dir = tempdir( CLEANUP => 1 );
  my ($fh,$filename) = tempfile( DIR => $dir, SUFFIX => ".txt" );
  print $fh $args{Text};
  chdir "/var/lib/myfrdcsa/sandbox/mead-3.12/mead-3.12";
  print Dumper({Files => [split /\n/, `ls $dir`]});
  my $res = `bin/addons/client/perl_client/mead_lite.pl -server localhost -port 6969 -d $dir`; # -sentences -absolute 10
  # my $res = `bin/addons/client/perl_client/mead_lite.pl -server localhost -port 6969 -d $dir -summary -sentences -absolute 10`;
  $fh = undef;
  return $res;
}

sub StartServer {
  my ($self,%args) = @_;
  chdir "/var/lib/myfrdcsa/sandbox/mead-3.12/mead-3.12";
  system "bin/addons/server/meadd";
}

sub StopServer {
  my ($self,%args) = @_;
  system "killall -9 meadd";
}

sub ServerRunning {
  my ($self,%args) = @_;
  my $res = `ps aux | grep bin/addons/server/meadd | grep -v grep`;
  return $res =~ /./;
}

sub DESTROY {
  my ($self,%args) = @_;
}

1;
