package System::Cyc;

use UniLang::Agent::Agent;
use UniLang::Util::Message;

use Text::Wrap;
use Net::Telnet;
use IO::Handle;

use strict;
use Carp;
use vars qw($VERSION);

$VERSION = '1.00';

use Class::MethodMaker new_with_init => 'new',
  get_set => [ qw / Host Port LogFile Prompt Log Cyc Agent / ];

sub init {
  my ($self,%args) = @_;
  $self->Host($args{host} || "localhost");
  $self->Port($args{port} || "3601");
  $self->LogFile($args{logfile} || "/tmp/cyc.log");
  $self->Prompt($args{prompt} || "> ");
}

sub Connect {
  my ($self,%args) = @_;
  my $LOG;
  open(LOG,">".$self->LogFile) or
    croak "Cannot open logfile: ".$self->LogFile;
  $self->Log($LOG);

  # verify that cyc is running
  $self->Cyc
    (Net::Telnet->new
     (Host => $self->Host,
      Port => $self->Port));

  $self->Cyc->open() or
    croak "Cannot open connection to ".$self->Host." ".$self->Port."\n";
}

sub Disconnect {
  my ($self,%args) = @_;
  my $LOG = $self->Log;
  close(LOG);
  $self->Cyc->close();
}

sub Send {
  my ($self,%args) = @_;
  $self->Cyc->print($args{Command});
}

sub Receive {
  my ($self,%args) = @_;
  my $res = $self->Cyc->getline();
  my $pretty = $res;
  $pretty =~ s/(\#\<AS)/\n$1/g;
  #print "$pretty";
  return $pretty;
}

sub Loop {
  my ($self,%args) = @_;
  print $self->Prompt;
  my $cmd;
  my $LOG = $self->Log;
  while (defined ($cmd = <>) && ($cmd !~ /^(quit|exit)$/)) {
    if ($cmd !~ /^$/) {
      $self->Send(Command => $cmd);
      my $res = $self->Receive;
      if ($res =~ /^200/) {
	print "$res";
	print LOG "$cmd";
	LOG->autoflush(1);
      }
    }
    print $self->Prompt;
  }
  $self->Disconnect;
}

sub AgentReceive {
  my ($self,%args) = @_;
  my $command = $args{Message}->Contents;
  $self->Send(Command => $command);
  # try line wrapping to avoid problems in emacs
  my $res = wrap("","",$self->Receive);
  $self->Agent->Reply
    (Message => $args{Message},
     Contents => $res);
}

sub Agentify {
  my ($self,%args) = @_;
  $self->Agent
    (UniLang::Agent::Agent->new
     (Name => "Cyc",
      ReceiveHandler => sub { $self->AgentReceive(@_) }));
  $self->Agent->DoNotDaemonize(1);
  $self->Agent->Register
    (Host => "localhost",
     Port => "9000");
}

1;
