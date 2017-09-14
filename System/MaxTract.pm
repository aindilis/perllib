package System::MaxTract;

# use Manager::Dialog qw(QueryUser);

use Data::Dumper;
use Expect;
use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyExpect FakeEnju Version Fast Debug /

  ];

sub init {
  my ($self,%args) = @_;
  $self->FakeEnju($args{FakeEnju});
  $self->Version($args{Version} || "2.4.2");
  $self->Debug($args{Debug} || 0);
}

sub StartEnju {
  my ($self,%args) = @_;
  if (! defined $self->MyExpect) {
    $self->StartServer(%args);
  }
}

sub StartServer {
  my ($self,%args) = @_;
  my $command;
  if ($args{Fast}) {
    $self->Fast(1);
    print "Using faster mogura Enju system\n";
    $command = "mogura";
  } elsif ($self->FakeEnju) {
    $command = "enju-fake";
  } else {
    $command = "enju";
  }
  my @parameters;
  $self->MyExpect(Expect->new);
  $self->MyExpect->raw_pty(1);
  $self->MyExpect->log_stdout($self->Debug);
  my $cwd;
  if ($self->Version eq "2.4.2") {
    my $newenjudir = "/var/lib/myfrdcsa/sandbox/enju-2.4.2/enju-2.4.2";
    $cwd = `pwd`;
    chomp $cwd;
    if (-d $newenjudir) {
      chdir $newenjudir;
    }
  }
  $self->MyExpect->spawn($command, @parameters)
    or die "Cannot spawn $command: $!\n";
  if ($self->Version eq "2.4.2") {
    chdir $cwd;
  }
  print "Waiting for parser to initialize...\n";
  $self->MyExpect->expect(300, [qr/Ready/, sub {print "Initialized.\n"}]);
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

sub ProcessSentence {
  my ($self,%args) = @_;
  my $sentence = $args{Sentence};
  $self->MyExpect->print("$sentence\n");
  $self->MyExpect->expect(300, [qr/./, sub {} ]);
  my $res = $self->MyExpect->match();
  $self->MyExpect->expect(300, [qr/^$/m, sub {} ]);
  $res .= $self->MyExpect->before();
  if (! $res) {
    # timed out, restart server
    $self->RestartServer;
    return {Fail => 1};
  } else {
    $self->MyExpect->clear_accum();
    return {Result => $res};
  }
}

sub ApplyEnjuToSentence {
  my ($self,%args) = @_;
  my $sentence = $args{Sentence};
  $sentence =~ s/\n/ /g;
  $sentence =~ s/\s+/ /g;
  if ($self->Fast or (length($sentence) < 150)) {
    print $sentence."\n";
    return $self->ProcessSentence
      (Sentence => $sentence);
  } else {
    return {SentenceTooLong => 1};
  }
}

sub ApplyEnjuToText {
  my ($self,%args) = @_;
  my $text = $args{Text};
  print "Getting sentences...\n";
  my $sentences = get_sentences($text);
  print "Done\n";
  my @results;
  foreach my $sentence (@$sentences) {
    push @results, $self->ProcessSentence
      (Sentence => $sentence);
  }
  return \@results;
}

sub ApplyEnjuToFile {
  my ($self,%args) = @_;
  my $f = $args{File};
  if (-f $f) {
    my $text = `cat "$f"`;
    return $self->ApplyEnjuToText
      (Type => $args{Type});
  } else {
    return {FileNotFound => 1};
  }
}

sub ApplyEnjuToQueryUser {
  my ($self,%args) = @_;
  while (1) {
    # my $sentence = QueryUser("Sentence?: ");
  }
}

1;
