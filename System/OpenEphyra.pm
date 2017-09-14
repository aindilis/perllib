package System::OpenEphyra;

use Data::Dumper;
use Expect;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyExpect /

  ];

sub init {
  my ($self,%args) = @_;
}

sub StartOpenEphyra {
  my ($self,%args) = @_;
  if (! defined $self->MyExpect) {
    $self->StartServer(%args);
  }
}

sub StartServer {
  my ($self,%args) = @_;
  chdir "/var/lib/myfrdcsa/sandbox/openephyra-0.1.2/openephyra-0.1.2/scripts/";
  my $command = "./OpenEphyra.sh";
  # my $command = "/var/lib/myfrdcsa/codebases/internal/perllib/System/OpenEphyra/sim.pl";
  my @parameters;
  $self->MyExpect(Expect->new);
  $self->MyExpect->raw_pty(1);
  $self->MyExpect->spawn($command, @parameters)
    or die "Cannot spawn $command: $!\n";
  print "Waiting for QA system to initialize...\n";
  $self->MyExpect->expect(300, [qr/Question: /, sub {print "Initialized.\n"}]);
  $self->MyExpect->clear_accum();
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

sub AskQuestion {
  my ($self,%args) = @_;
  my $question = $args{Question};
  $self->MyExpect->print("$question\n");
  $self->MyExpect->expect(300, [qr/./, sub {} ]);
  my $res = $self->MyExpect->match();
  $self->MyExpect->expect(300, [qr/Question: /m, sub {} ]);
  $res .= $self->MyExpect->before();
  if (! $res) {
    # timed out, restart server
    $self->RestartServer;
    return {Fail => 1};
  } else {
    $self->MyExpect->clear_accum();
    # now extract the result
    return {Result => $self->ExtractResult(Text => $res)};
  }
}

sub ExtractResult {
  my ($self,%args) = @_;
  my $text = $args{Text};
  $text =~ /Answer:\n(.*)$/s;
  my $snippet = $1;
  my @items = split /\n/,$snippet;
  my $result = shift @items;
  $result =~ s/\[.*?\]\s+(.*)$/$1/;
  my $score = shift @items;
  $score =~ s/Score: //;
  my $document = shift @items;
  $document =~ s/Document: //;
  return [{Result => $result, Score => $score, Document => $document}];
}

1;
