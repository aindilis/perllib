package PerlLib::ServerManager;

# this will be a system that will make writing things with expect
# quicker for our purposes, things like Enju, Cyc, etc

use Data::Dumper;
use Expect;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyExpect Debug /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Debug($args{Debug} || 0);
  $self->Start(%args);
}

sub Start {
  my ($self,%args) = @_;
  if (! defined $self->MyExpect) {
    $self->StartCommand(%args);
  }
}

sub StartCommand {
  my ($self,%args) = @_;
  $self->MyExpect(Expect->new);
  $self->MyExpect->raw_pty(1);
  $self->MyExpect->log_stdout($self->Debug);
  $self->MyExpect->spawn($args{Command}, @parameters)
    or die "Cannot spawn ".$args{Command}.": $!\n";
  print "Waiting for server to become initialized...\n";
  my $regex;
  if (exists $args{Initialized}) {
    my $initialized = $args{Initialized};
    my $ref = ref $initialized;
    if ($ref eq "Regexp") {
      $regex = $initialized;
    } elsif ($ref eq "") {
      $initialized =~ s/([^a-zA-Z0-9])/\\$1/g;
      # print $initialized."\n";
      $regex = qr/$initialized/;
    }
    my $sub = $args{Callback} || sub {print "Initialized.\n"};
    $self->MyExpect->expect($args{Timeout} || 300, [$regex, $sub]);
    $self->MyExpect->clear_accum();
  }
}

sub MyMainLoop {
  my ($self,%args) = @_;
  # we want to listen to expect and then alternate between agent listening
  my $delay = 0.05;
  while (1) {
    my $seen = 0;
    if (defined $self->MyExpect) {
      $seen = 1;
      # FIX ME
      $self->MyExpect->expect
	($delay, [qr/jkdsjlfakj/,sub {print "Huh?\n"}]);
    }
    if (defined $UNIVERSAL::agent) {
      $seen = 1;
      $UNIVERSAL::agent->Listen
	(
	 TimeOut => $delay,
	);
    }
    if (! $seen) {
      sleep 5;
    }
  }
}

sub Stop {
  my ($self,%args) = @_;
  $self->MyExpect->soft_close();
  # $self->MyExpect->hard_close();
}

1;
